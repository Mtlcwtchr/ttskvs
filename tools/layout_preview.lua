-- Предпросмотр вёрстки картинкой, без запуска TTS.
--
--   lua tools/layout_preview.lua view   > out.html
--   lua tools/layout_preview.lua wizard > out.html
--
-- Берёт то самое дерево с посчитанной геометрией, что уедет в игру, и рисует
-- его абсолютно позиционированными блоками: каждый Panel — прямоугольник со
-- своим цветом, каждый Text — своя строка нужным кеглем. Это не «похожая
-- картинка», а ровно те же числа, которые получит TTS, поэтому по ней видно
-- и наезды, и пустоты, и то, что подпись не влезла.
--
-- Что заведомо иначе, чем в игре: шрифт (в TTS свой), сглаживание, поведение
-- resizeTextForBestFit (здесь эмулируется простым сжатием по длине строки).
package.path = "src/?.lua;" .. package.path

local Layout = require("ui.Layout")
local Markup = require("ui.Markup")
local Templates = require("ui.generated.Templates")
local Theme = require("ui.Theme")

local mode = ({ ... })[1] or "view"

local PARTY = {
  {
    id = "c1",
    name = "Мира Светлоокая",
    race = "Полуэльф",
    class = "Волшебница",
    level = 3,
    age = 27,
    alignment = "Хаотично-доброе",
    playerName = "Аня",
    hp = { current = 16, max = 18, temp = 2 },
    stamina = { current = 7, max = 10 },
    mana = { current = 4, max = 6 },
    speed = 30,
    hitDice = "3d6",
    proficiencyBonus = 2,
    abilityScores = { STR = 8, DEX = 14, CON = 12, INT = 17, WIS = 13, CHA = 10 },
    proficientSkills = { "arcana", "investigation", "insight" },
    savingThrowProficiencies = { "INT", "WIS" },
    combat = { armorClass = 12, meleeBonus = 1, rangedBonus = 5 },
    equipment = {
      { slot = "mail", name = "Мантия" },
      { slot = "amulet", name = "Амулет" },
    },
    inventory = {
      { name = "Посох", qty = 1 },
      { name = "Гримуар", qty = 1 },
      { name = "Зелье", qty = 3 },
      { name = "Верёвка", qty = 1 },
    },
    abilities = {
      { id = "a1", name = "Волшебная стрела", actionType = "action", description = "3 снаряда по 1d4+1, урон силовой." },
      { id = "a2", name = "Щит", actionType = "reaction", description = "+5 к КД до начала следующего хода." },
    },
    otherProficiencies = { "Языки: Общий, Эльфийский, Драконий", "Владение: посохи, кинжалы" },
    personality = {
      traits = "Записывает каждую находку в дневник.",
      ideals = "Знание должно быть свободным.",
      bonds = "Ищет утраченный гримуар наставницы.",
      flaws = "Не может пройти мимо неразгаданной тайны.",
    },
    background = "Ученица Академии",
    customGroups = { { title = "ДОЛГ", description = "Обещала вернуть книгу в срок." } },
  },
  { id = "c2", name = "Келлен", hp = { current = 9, max = 22 } },
}

local composed = Markup.compose(Templates.MainUI, {
  party = PARTY,
  selectedCharacterId = "c1",
  sheetVisible = true,
  mode = mode,
  character = PARTY[1],
})
local root = Layout.build(composed)

local out = {}
local function push(text)
  table.insert(out, text)
end

local function attr(node, name)
  local value = node.attrs[name]
  if value == nil then
    return nil
  end
  return Theme.resolve(value)
end

local function escape(text)
  return (tostring(text):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function textOf(node)
  local parts = {}
  for _, kid in ipairs(node.kids) do
    if kid.text ~= nil then
      table.insert(parts, kid.text)
    end
  end
  return (table.concat(parts):gsub("^%s+", ""):gsub("%s+$", ""))
end

local FLOW_TAGS = { Row = true, Col = true, Scroll = true, Box = true, Anchor = true }

local function walk(node)
  for _, kid in ipairs(node.kids) do
    if kid.text == nil and not kid.verbatim then
      local color = attr(kid, "color")
      -- Координаты относительно родителя: только так вложенность в HTML
      -- совпадает с деревом, а <Scroll> действительно обрезает содержимое —
      -- в игре это делает маска VerticalScrollView.
      local style = string.format(
        "left:%dpx;top:%dpx;width:%dpx;height:%dpx;",
        kid.x - node.x, kid.y - node.y, kid.w, kid.h
      )
      -- <Scroll> режет содержимое маской, <Text> — обрезается по своей рамке
      -- (verticalOverflow="Truncate" по умолчанию). Остальное не обрезается.
      if kid.tag == "Scroll" or kid.tag == "Text" then
        style = style .. "overflow:hidden;"
      else
        style = style .. "overflow:visible;"
      end
      if FLOW_TAGS[kid.tag] then
        if color ~= nil then
          style = style .. "background:" .. color .. ";"
        end
        push('<div class="b" style="' .. style .. '">')
        walk(kid)
        push("</div>")
      elseif kid.tag == "Button" then
        local colors = attr(kid, "colors") or "#333"
        local background = colors:match("^([^|]+)") or colors
        style = style .. "background:" .. background .. ";color:" .. (attr(kid, "textColor") or "#fff") .. ";"
        style = style .. "font-size:" .. (kid.attrs.fontSize or 14) .. "px;"
        push('<div class="b t center" style="' .. style .. '">' .. escape(textOf(kid)) .. "</div>")
        walk(kid)
      elseif kid.tag == "InputField" then
        local colors = attr(kid, "colors") or "#111"
        local background = colors:match("^([^|]+)") or colors
        style = style .. "background:" .. background .. ";color:" .. (attr(kid, "textColor") or "#fff") .. ";"
        style = style .. "font-size:" .. (kid.attrs.fontSize or 13) .. "px;outline:1px solid #57452c;"
        push('<div class="b t left" style="' .. style .. '">' .. escape(kid.attrs.text or "") .. "</div>")
        walk(kid)
      elseif kid.tag == "Text" then
        local align = kid.attrs.alignment or "MiddleCenter"
        local horizontal = "center"
        if align:find("Left") then horizontal = "flex-start" end
        if align:find("Right") then horizontal = "flex-end" end
        local vertical = "center"
        if align:find("^Upper") then vertical = "flex-start" end
        if align:find("^Lower") then vertical = "flex-end" end
        if kid.attrs.horizontalOverflow == "Wrap" then
          style = style .. "white-space:normal;"
        end
        style = style .. "color:" .. (color or "#ddd") .. ";"
          .. "font-size:" .. (kid.attrs.fontSize or 14) .. "px;"
          .. "justify-content:" .. horizontal .. ";align-items:" .. vertical .. ";"
        push('<div class="b t" style="' .. style .. '">' .. escape(textOf(kid)) .. "</div>")
        walk(kid)
      else
        push('<div class="b" style="' .. style .. 'outline:1px dashed #555;">')
        walk(kid)
        push("</div>")
      end
    end
  end
end

walk(root)

print([[<!doctype html><meta charset="utf-8"><style>
body { margin:0; background:#0c0b0a; font-family:Georgia, 'Times New Roman', serif; }
#c { position:relative; width:1600px; height:1000px; }
.b { position:absolute; box-sizing:border-box; }
.t { display:flex; line-height:1.05; white-space:nowrap; padding:0 2px; }
.center { justify-content:center; align-items:center; }
.left { justify-content:flex-start; align-items:center; }
</style><div id="c">]] .. table.concat(out) .. "</div>")
