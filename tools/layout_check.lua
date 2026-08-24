-- Проверка вёрстки БЕЗ запуска TTS: собирает Global UI на выдуманной партии и
-- считает геометрию так же, как это сделает игра.
--
--   lua tools/layout_check.lua           только проверки
--   lua tools/layout_check.lua --dump    ещё и дерево с посчитанными рамками
--   lua tools/layout_check.lua --xml     готовый XML (view-режим)
--
-- Что именно проверяется (это те самые отказы, из-за которых «ехало всё»):
--   * ни один элемент не выходит за границы родителя;
--   * соседи по строке/столбцу не пересекаются;
--   * ни у одного элемента нет нулевого или отрицательного размера
--     (нулевая ширина = невидимый элемент — самый тихий из отказов);
--   * в готовом XML не осталось ни подстановок {{}}, ни нераскрытых тегов.
package.path = "src/?.lua;" .. package.path

local Layout = require("ui.Layout")
-- В тестах несобранная раскладка должна падать, а не печатать предупреждение.
Layout.strict = true

local Markup = require("ui.Markup")
local Templates = require("ui.generated.Templates")
local UIBuilder = require("ui.builders.UIBuilder")

local PARTY = {
  {
    id = "c1",
    name = "Мира Светлоокая",
    race = "Полуэльф",
    class = "Плут",
    level = 5,
    age = 27,
    alignment = "Хаотично-доброе",
    playerName = "Аня",
    hp = { current = 24, max = 38, temp = 3 },
    stamina = { current = 7, max = 10 },
    mana = { current = 2, max = 6 },
    abilities = {
      { id = "a1", name = "Скрытая атака", actionType = "action", description = "Урон +2d6 при преимуществе" },
      { id = "a2", name = "Уход", actionType = "bonus", description = "Отступление без провокации" },
    },
    attacks = { { name = "Кинжал", atkBonus = "+7", damage = "1d4+4" } },
    inventory = { { name = "Верёвка", qty = 1 }, { name = "Отмычки", qty = 2 } },
    skills = { { name = "Скрытность", ability = "Dex", bonus = 9 } },
    savingThrowProficiencies = { "DEX", "INT" },
    otherProficiencies = { "Общий", "Эльфийский" },
    customGroups = { { title = "Долг", description = "Найти брата" } },
    -- Скидка 50% — значение с процентом намеренно: на нём когда-то ломалась
    -- подстановка (см. CLAUDE.md, «капканы движка»).
    background = "Воровка. Скидка 50% у контрабандистов",
  },
  {
    id = "c2",
    name = "Гром",
    hp = { current = 40, max = 40 },
  },
}

local args = {}
for _, value in ipairs({ ... }) do
  args[value] = true
end

local failures = {}

local function report(message)
  table.insert(failures, message)
end

local function path(node)
  local parts = {}
  local current = node
  while current ~= nil and current.tag ~= "#root" do
    local id = current.attrs.id
    table.insert(parts, 1, current.tag .. ((id ~= nil and id ~= "") and ("#" .. id) or ""))
    current = current.parent
  end
  return table.concat(parts, " > ")
end

-- <Defaults> в раскладке не участвует (это таблица стилей, а не элемент),
-- поэтому геометрии у него нет и проверять её нечего.
local function elements(node)
  local list = {}
  for _, kid in ipairs(node.kids or {}) do
    if kid.text == nil and not kid.verbatim then
      table.insert(list, kid)
    end
  end
  return list
end

-- Прямоугольники пересекаются? Допуск 0 — раскладка целочисленная.
local function overlaps(a, b)
  return a.x < b.x + b.w and b.x < a.x + a.w
    and a.y < b.y + b.h and b.y < a.y + a.h
end

local function checkTree(node, mode)
  local kids = elements(node)
  for _, kid in ipairs(kids) do
    kid.parent = node

    -- Нулевой размер у пустого блока — законная штука (полоска ресурса на 0%),
    -- а вот нулевой контейнер или нулевой текст прячут содержимое.
    local hidesContent = #elements(kid) > 0
      or kid.tag == "Text" or kid.tag == "Button" or kid.tag == "InputField"
    if (kid.w <= 0 or kid.h <= 0) and hidesContent then
      report(string.format(
        "[%s] нулевой размер %dx%d: %s",
        mode, kid.w, kid.h, path(kid)
      ))
    end

    if node.tag ~= "#root" then
      local slack = 1
      local insideX = kid.x >= node.x - slack and kid.x + kid.w <= node.x + node.w + slack
      local insideY = kid.y >= node.y - slack and kid.y + kid.h <= node.y + node.h + slack
      -- Внутри <Scroll> содержимое имеет право быть длиннее окна — это и есть
      -- прокрутка, а не поломанная вёрстка.
      if not (insideX and insideY) and node.flow ~= "scroll" then
        report(string.format(
          "[%s] вылезает за родителя: %s\n      ребёнок %dx%d @ %d,%d, родитель %dx%d @ %d,%d",
          mode, path(kid), kid.w, kid.h, kid.x, kid.y, node.w, node.h, node.x, node.y
        ))
      end
    end
  end

  -- Наезд соседей: главная регрессия, из-за которой всё это переделывалось.
  for i = 1, #kids do
    for j = i + 1, #kids do
      local a, b = kids[i], kids[j]
      if node.flow ~= false and node.flow ~= nil and overlaps(a, b) then
        report(string.format(
          "[%s] соседи наезжают друг на друга внутри %s:\n      %s (%dx%d @ %d,%d)\n      %s (%dx%d @ %d,%d)",
          mode, path(node),
          a.tag, a.w, a.h, a.x, a.y,
          b.tag, b.w, b.h, b.x, b.y
        ))
      end
    end
  end

  for _, kid in ipairs(kids) do
    checkTree(kid, mode)
  end
end

local function countTags(xml)
  local counts = {}
  for tag in xml:gmatch("<(%a[%w_]*)") do
    counts[tag] = (counts[tag] or 0) + 1
  end
  return counts
end

local PRIMITIVES = { "Row", "Col", "Box", "Scroll", "Anchor" }

for _, mode in ipairs({ "view", "wizard" }) do
  local context = {
    party = PARTY,
    selectedCharacterId = "c1",
    sheetVisible = true,
    mode = mode,
    character = PARTY[1],
  }

  local composed = Markup.compose(Templates.MainUI, context)
  local tree = Layout.build(composed)
  -- Претензии самого решателя (не влезли фиксированные дети) — такие же
  -- проблемы, как наезд: собираем в общий список, а не роняем первым же.
  for _, message in ipairs(Layout.problems) do
    report("[" .. mode .. "] " .. message)
  end
  checkTree(tree, mode)

  local xml = UIBuilder.buildMainUI(PARTY, "c1", true, mode)
  -- Элементы внутри <Defaults> — не элементы, а базовые атрибуты, размеров у
  -- них быть не должно: из проверок этот блок исключаем.
  local checked = xml:gsub("<Defaults>.-</Defaults>", "")

  if xml:find("{{", 1, true) ~= nil then
    report("[" .. mode .. "] в готовом XML осталась подстановка {{...}}")
  end
  for _, name in ipairs(PRIMITIVES) do
    if checked:find("<" .. name, 1, true) ~= nil then
      report("[" .. mode .. "] примитив <" .. name .. "> не превратился в TTS XML")
    end
  end
  -- Каждый Panel/Text/Button обязан получить посчитанный размер: без него TTS
  -- падает обратно на «как получится», и вёрстка снова становится гаданием.
  -- Исключение ровно одно: корневой Panel на весь холст (у него размера быть и
  -- не должно, иначе UI перестанет зависеть от разрешения экрана).
  local rootSeen = false
  for tag in ("Panel Text Button InputField"):gmatch("%a+") do
    for chunk in checked:gmatch("<" .. tag .. "([^>]*)>") do
      if chunk:find('width="') == nil or chunk:find('height="') == nil then
        if tag == "Panel" and not rootSeen then
          rootSeen = true
        else
          report("[" .. mode .. "] <" .. tag .. "> без размера: <" .. tag .. chunk .. ">")
          break
        end
      end
    end
  end

  local counts = countTags(xml)
  print(string.format(
    "%-7s %6d символов, Panel %d, Text %d, Button %d, InputField %d",
    mode, #xml, counts.Panel or 0, counts.Text or 0, counts.Button or 0, counts.InputField or 0
  ))

  if args["--dump"] then
    print(Layout.dump(composed))
  end
  if args["--xml"] and mode == "view" then
    print(xml)
  end
end

if #failures > 0 then
  -- Одна настоящая причина («дети не влезли») тянет за собой десятки
  -- следствий — нулевые размеры у всего, что делило остаток. Показываем
  -- начало списка: первые строки и есть причина, остальное — эхо.
  local LIMIT = 12
  print("\n" .. #failures .. " проблем(ы) вёрстки:")
  for index, message in ipairs(failures) do
    if index > LIMIT then
      print("  ... и ещё " .. (#failures - LIMIT) .. " — почините первые, остальное обычно уходит вместе с ними")
      break
    end
    print("  " .. message)
  end
  os.exit(1)
end

print("вёрстка сходится: ничего не наезжает, не вылезает и не нулевое")
