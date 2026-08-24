-- Решатель раскладки: превращает четыре примитива разметки (<Row>, <Col>,
-- <Box>, <Scroll> плюс <Anchor> для абсолютного позиционирования) в готовый
-- TTS XML, где У КАЖДОГО элемента посчитан конкретный размер в пикселях.
--
-- Зачем он вообще нужен. В TTS размер живёт только на Panel, а layout-группы
-- по умолчанию переопределяют размеры детей. Раньше из этого следовало, что
-- каждое число в разметке писалось руками на каждом уровне вложенности:
-- Sheet 1320 -> padding 16 -> Panel 1288 -> колонка 478 -> Box 466 -> плитка
-- 148. Ни одно из этих чисел не выводилось из другого, поэтому правка одного
-- размера означала ручной пересчёт десятка соседей — «поехало всё».
--
-- Tеперь размер объявляется НАМЕРЕНИЕМ, а пиксели считает этот модуль:
--
--   width="240"   ровно 240 пикселей
--   width="fill"  занять весь остаток вдоль потока (поровну с такими же),
--                 а поперёк потока — всю ширину/высоту родителя
--   width="2fr"   как fill, но с весом: 2fr получит вдвое больше, чем 1fr
--   width="50%"   половина внутреннего размера родителя
--   width="auto"  по содержимому (сумма детей вдоль потока, максимум поперёк)
--
-- Гарантии, которые это даёт:
--   * дети раскладываются потоком и физически не могут наехать друг на друга
--     (никаких offset-ов «на глазок»);
--   * сумма размеров детей всегда равна внутреннему размеру родителя, потому
--     что остаток делится, а не задаётся вручную;
--   * если фиксированные дети не влезли, это ошибка с именем контейнера и
--     числами, а не молчаливый наезд;
--   * опечатка в имени атрибута раскладки — тоже ошибка (в песочнице TTS
--     линтера нет, иначе «gepth=10» проявился бы кривой вёрсткой).
local Layout = {}

-- Опорный холст: нужен ровно для того, чтобы разрешить fill/% на самом
-- верхнем уровне (у корня MainUI своего размера нет). Всё внутри считается от
-- размеров родителя, поэтому на эти числа больше ничего не опирается.
Layout.screen = { width = 1920, height = 1080 }

-- Единственное место с «естественными» размерами листьев. Tекст в песочнице
-- измерить нечем, поэтому строка = кегль * коэффициент. Хочется плотнее или
-- свободнее — правится здесь, а не в тридцати местах разметки.
Layout.metrics = {
  lineFactor = 1.45,
  -- До какой доли кегля тексту разрешено сжиматься, чтобы влезть в ячейку.
  minFontRatio = 0.62,
  Button = 30,
  InputField = 28,
  Toggle = 24,
  Dropdown = 28,
  Slider = 24,
  Image = 24,
  default = 24,
  -- Ширина вертикального скроллбара: на неё сужается содержимое <Scroll>.
  scrollbar = 20,
}

-- Список претензий последнего прохода: «не влезли дети» — это не повод рушить
-- весь HUD (UI строится одной строкой, error() оставил бы пустой экран), но и
-- молчать нельзя. В игре warn печатает в консоль сразу, в тестах — собирается
-- сюда и печатается списком целиком (tools/layout_check.lua, Layout.strict).
Layout.problems = {}
Layout.strict = false

local function fail(message)
  error("Layout: " .. message, 0)
end

local function warn(message)
  table.insert(Layout.problems, message)
  if not Layout.strict then
    -- print есть и в TTS, и в обычном Lua.
    print("[KVS] Layout: " .. message)
  end
end

----------------------------------------------------------------- примитивы --

-- Направление потока: x — в строку, y — в столбец, scroll — столбец в окне
-- прокрутки, false — потока нет (дети накладываются, каждый по своему `at`).
local FLOW = {
  Row = "x",
  Col = "y",
  Scroll = "scroll",
  Box = false,
  Anchor = false,
}

-- <Defaults> — не элемент, а базовые атрибуты для всех элементов ниже
-- (api.tabletopsimulator.com/ui/defaults). Размеров у его детей быть не должно:
-- посчитай им ширину — и она станет размером по умолчанию для всего текста.
local VERBATIM = { Defaults = true }

local COMMON_ATTRS = {
  id = true, width = true, height = true, color = true, at = true, padding = true,
  active = true, visibility = true, tooltip = true, raycastTarget = true,
}
-- gap/align имеют смысл только там, где есть поток: у <Box> детям делить
-- нечего, они лежат друг на друге по своему `at`.
local FLOW_ATTRS = { gap = true, align = true }
local ANCHOR_ATTRS = { x = true, y = true }

local function allowedAttrs(tag)
  local allowed = {}
  for key in pairs(COMMON_ATTRS) do
    allowed[key] = true
  end
  if FLOW[tag] then
    for key in pairs(FLOW_ATTRS) do
      allowed[key] = true
    end
  end
  if tag == "Anchor" then
    for key in pairs(ANCHOR_ATTRS) do
      allowed[key] = true
    end
  end
  return allowed
end

-- Человеческие имена вместо UpperLeft/MiddleCenter: «куда прижать».
local ALIGNMENTS = {
  topleft = "UpperLeft", top = "UpperCenter", topright = "UpperRight",
  left = "MiddleLeft", center = "MiddleCenter", right = "MiddleRight",
  bottomleft = "LowerLeft", bottom = "LowerCenter", bottomright = "LowerRight",
}
local RAW_ALIGNMENTS = {}
for _, value in pairs(ALIGNMENTS) do
  RAW_ALIGNMENTS[value] = true
end

local function alignment(value, fallback)
  if value == nil or value == "" then
    return fallback
  end
  local text = tostring(value)
  if RAW_ALIGNMENTS[text] then
    return text
  end
  local resolved = ALIGNMENTS[text:lower()]
  if resolved == nil then
    fail("непонятное выравнивание '" .. text .. "' (topleft/top/topright/left/center/right/bottomleft/bottom/bottomright)")
  end
  return resolved
end

------------------------------------------------------------- размеры (spec) --

-- Разбор объявления размера в структуру. Число — пиксели, fill/Nfr — доля
-- остатка, N% — доля родителя, auto — по содержимому.
local function parseSize(value, axis, tag)
  if value == nil then
    return nil
  end
  if type(value) == "number" then
    return { kind = "px", value = value }
  end
  local text = tostring(value)
  if text == "fill" then
    return { kind = "flex", weight = 1 }
  end
  if text == "auto" then
    return { kind = "auto" }
  end
  local weight = text:match("^(%d+%.?%d*)fr$")
  if weight ~= nil then
    return { kind = "flex", weight = tonumber(weight) }
  end
  local percent = text:match("^(%d+%.?%d*)%%$")
  if percent ~= nil then
    return { kind = "percent", value = tonumber(percent) / 100 }
  end
  local pixels = tonumber(text)
  if pixels ~= nil then
    return { kind = "px", value = pixels }
  end
  fail(
    "непонятный размер " .. axis .. "=\"" .. text .. "\" у <" .. tag .. ">"
      .. " (число, fill, Nfr, N%, auto)"
  )
end

-- padding="8" | "8 12" (по горизонтали, по вертикали) | "8 12 4 6"
-- (left right top bottom — тот же порядок, что у TTS).
local function parsePadding(value)
  if value == nil then
    return { 0, 0, 0, 0 }
  end
  local parts = {}
  for chunk in tostring(value):gmatch("[-%d%.]+") do
    table.insert(parts, tonumber(chunk) or 0)
  end
  if #parts == 0 then
    return { 0, 0, 0, 0 }
  elseif #parts == 1 then
    return { parts[1], parts[1], parts[1], parts[1] }
  elseif #parts == 2 then
    return { parts[1], parts[1], parts[2], parts[2] }
  elseif #parts == 4 then
    return parts
  end
  fail("padding=\"" .. tostring(value) .. "\": ожидается 1, 2 или 4 числа")
end

------------------------------------------------------------------ разбор XML --

-- Закрывающий ">", не спотыкаясь о ">" внутри кавычек (те же грабли, что в
-- Markup: значение атрибута может содержать угловые скобки).
local function findTagEnd(source, from)
  local i = from
  while i <= #source do
    local c = source:sub(i, i)
    if c == '"' then
      local close = source:find('"', i + 1, true)
      if close == nil then
        return nil
      end
      i = close + 1
    elseif c == ">" then
      return i
    else
      i = i + 1
    end
  end
  return nil
end

local function parseAttrs(chunk)
  local attrs, order = {}, {}
  for name, value in chunk:gmatch('([A-Za-z_][A-Za-z0-9_%-]*)%s*=%s*"([^"]*)"') do
    if attrs[name] == nil then
      table.insert(order, name)
    end
    attrs[name] = value
  end
  return attrs, order
end

local function addText(node, text)
  if text == nil or text:match("^%s*$") ~= nil then
    return
  end
  table.insert(node.kids, { text = text })
end

local function parse(xml)
  local root = { tag = "#root", attrs = {}, order = {}, kids = {} }
  local stack = { root }
  local pos = 1

  while true do
    local top = stack[#stack]
    local open = xml:find("<", pos, true)
    if open == nil then
      addText(top, xml:sub(pos))
      break
    end
    addText(top, xml:sub(pos, open - 1))

    if xml:sub(open + 1, open + 3) == "!--" then
      local commentEnd = xml:find("-->", open + 4, true)
      if commentEnd == nil then
        fail("незакрытый комментарий")
      end
      pos = commentEnd + 3
    elseif xml:sub(open + 1, open + 1) == "/" then
      local tagEnd = xml:find(">", open, true)
      if tagEnd == nil then
        fail("незакрытый закрывающий тег")
      end
      local name = xml:sub(open + 2, tagEnd - 1):match("^%s*([%w_]+)")
      if #stack < 2 then
        fail("лишний закрывающий тег </" .. tostring(name) .. ">")
      end
      if top.tag ~= name then
        fail("ожидался </" .. top.tag .. ">, встретился </" .. tostring(name) .. ">")
      end
      table.remove(stack)
      pos = tagEnd + 1
    else
      local name = xml:match("^<([%a][%w_]*)", open)
      if name == nil then
        -- Не тег (например «<» в тексте) — оставляем как текст.
        addText(top, xml:sub(open, open))
        pos = open + 1
      else
        local tagEnd = findTagEnd(xml, open)
        if tagEnd == nil then
          fail("незакрытый тег <" .. name)
        end
        local chunk = xml:sub(open + #name + 1, tagEnd - 1)
        local attrs, order = parseAttrs(chunk)
        local node = { tag = name, attrs = attrs, order = order, kids = {} }
        table.insert(top.kids, node)
        if chunk:match("/%s*$") == nil then
          table.insert(stack, node)
        end
        pos = tagEnd + 1
      end
    end
  end

  if #stack > 1 then
    fail("не закрыт тег <" .. stack[#stack].tag .. ">")
  end
  return root
end

--------------------------------------------------------------- подготовка --

local function prepare(node)
  if node.text ~= nil then
    return
  end

  local tag = node.tag
  if VERBATIM[tag] then
    node.verbatim = true
    node.pad = { 0, 0, 0, 0 }
    node.gap = 0
    node.intrinsicW, node.intrinsicH = 0, 0
    node.contentW, node.contentH = 0, 0
    node.w, node.h, node.x, node.y = 0, 0, 0, 0
    return
  end
  node.flow = FLOW[tag]
  node.primitive = FLOW[tag] ~= nil

  if node.primitive then
    local allowed = allowedAttrs(tag)
    for _, key in ipairs(node.order) do
      if not allowed[key] then
        local names = {}
        for name in pairs(allowed) do
          table.insert(names, name)
        end
        table.sort(names)
        fail(
          "<" .. tag .. ">: неизвестный атрибут " .. key
            .. " (можно: " .. table.concat(names, ", ") .. ")"
        )
      end
    end
  end

  node.specW = parseSize(node.attrs.width, "width", tag)
  node.specH = parseSize(node.attrs.height, "height", tag)
  node.pad = parsePadding(node.attrs.padding)
  node.gap = tonumber(node.attrs.gap) or 0

  local elementKids = 0
  for _, kid in ipairs(node.kids) do
    if kid.text == nil then
      elementKids = elementKids + 1
    end
  end

  -- Ширину текста/поля в песочнице измерить нечем, поэтому «ширина не задана»
  -- у листа означает fill, а не 0: иначе строка молча получала бы нулевую
  -- ширину и исчезала — ровно тот тихий отказ, от которого мы уходим.
  if elementKids == 0 and node.specW == nil then
    node.specW = { kind = "flex", weight = 1 }
  end

  for _, kid in ipairs(node.kids) do
    kid.parent = node
    prepare(kid)
  end
end

------------------------------------------------------------------- измерение --

-- Естественная высота листа: строка текста считается от кегля, у остальных
-- элементов — фиксированная из Layout.metrics.
local function leafHeight(node)
  if node.tag == "Text" then
    local fontSize = tonumber(node.attrs.fontSize) or 12
    return math.ceil(fontSize * Layout.metrics.lineFactor)
  end
  return Layout.metrics[node.tag] or Layout.metrics.default
end

local function elements(node)
  local list = {}
  for _, kid in ipairs(node.kids) do
    -- <Defaults> в раскладке не участвует: ни размера, ни места в потоке.
    if kid.text == nil and not kid.verbatim then
      table.insert(list, kid)
    end
  end
  return list
end

-- Собственный размер по содержимому (нужен для auto и как минимум для потока).
local function measure(node)
  local kids = elements(node)
  for _, kid in ipairs(kids) do
    measure(kid)
  end

  local contentW, contentH = 0, 0
  local flow = node.flow

  if flow == "x" then
    for index, kid in ipairs(kids) do
      contentW = contentW + kid.intrinsicW + (index > 1 and node.gap or 0)
      contentH = math.max(contentH, kid.intrinsicH)
    end
  elseif flow == "y" or flow == "scroll" then
    for index, kid in ipairs(kids) do
      contentH = contentH + kid.intrinsicH + (index > 1 and node.gap or 0)
      contentW = math.max(contentW, kid.intrinsicW)
    end
  else
    for _, kid in ipairs(kids) do
      contentW = math.max(contentW, kid.intrinsicW)
      contentH = math.max(contentH, kid.intrinsicH)
    end
  end

  node.contentW = contentW
  node.contentH = contentH

  local padW = node.pad[1] + node.pad[2]
  local padH = node.pad[3] + node.pad[4]

  local specW, specH = node.specW, node.specH
  if specW ~= nil and specW.kind == "px" then
    node.intrinsicW = specW.value
  else
    node.intrinsicW = contentW + padW
  end
  if specH ~= nil and specH.kind == "px" then
    node.intrinsicH = specH.value
  elseif #kids > 0 then
    node.intrinsicH = contentH + padH
  else
    node.intrinsicH = leafHeight(node) + padH
  end
end

------------------------------------------------------------------- раскладка --

local function round(value)
  return math.floor(value + 0.5)
end

-- Размер по одной оси, когда доступное место известно.
local function resolveSize(spec, available, intrinsic, fallbackFlex)
  if spec == nil then
    return fallbackFlex and available or intrinsic
  end
  if spec.kind == "px" then
    return spec.value
  elseif spec.kind == "percent" then
    return round(available * spec.value)
  elseif spec.kind == "auto" then
    return intrinsic
  end
  -- flex поперёк потока = «на всю ширину/высоту родителя».
  return available
end

-- Путь до узла: без него сообщение «дети не влезли» указывает на один из
-- полутора сотен <Row>, и искать приходится глазами.
local function describe(node)
  local parts = {}
  local current = node
  while current ~= nil and current.tag ~= "#root" do
    local id = current.attrs.id
    table.insert(parts, 1, current.tag .. ((id ~= nil and id ~= "") and ("#" .. id) or ""))
    current = current.parent
  end
  return table.concat(parts, " > ")
end

local arrange

-- Спецификация и естественный размер по нужной оси. Отдельными функциями, а не
-- через `horizontal and kid.specH or kid.specW`: спек по оси имеет полное право
-- быть nil («размер не задан»), и такое выражение молча подставляло спек ДРУГОЙ
-- оси — из-за этого строка навыка получала высоту, равную своей ширине.
local function mainSpec(kid, horizontal)
  if horizontal then
    return kid.specW
  end
  return kid.specH
end

local function crossSpec(kid, horizontal)
  if horizontal then
    return kid.specH
  end
  return kid.specW
end

-- Разбор выравнивания на две составляющие: вдоль оси и поперёк.
-- Нужно, чтобы посчитанные позиции совпадали с тем, что рисует TTS: группа
-- прижимает блок детей по childAlignment, и без этого дамп геометрии врал бы
-- ровно там, где содержимое не занимает всю строку.
local function alignFactors(place, horizontal)
  local vertical = 0.5
  if place:find("^Upper") ~= nil then
    vertical = 0
  elseif place:find("^Lower") ~= nil then
    vertical = 1
  end
  local across = 0.5
  if place:find("Left$") ~= nil then
    across = 0
  elseif place:find("Right$") ~= nil then
    across = 1
  end
  if horizontal then
    return across, vertical
  end
  return vertical, across
end

-- Поток: вдоль оси делим остаток между flex-детьми, поперёк — растягиваем.
local function arrangeFlow(node, kids, horizontal, innerW, innerH, originX, originY)
  local mainAvailable = horizontal and innerW or innerH
  local crossAvailable = horizontal and innerH or innerW
  local gaps = node.gap * math.max(0, #kids - 1)

  local used, weight = 0, 0
  local mains = {}
  for index, kid in ipairs(kids) do
    local spec = mainSpec(kid, horizontal)
    if spec ~= nil and spec.kind == "flex" then
      weight = weight + spec.weight
      mains[index] = nil
    else
      local intrinsic = kid.intrinsicH
      if horizontal then
        intrinsic = kid.intrinsicW
      end
      mains[index] = resolveSize(spec, mainAvailable, intrinsic, false)
      used = used + mains[index]
    end
  end

  local free = mainAvailable - gaps - used
  if free < -0.5 then
    warn(
      describe(node) .. ": дети не влезают вдоль "
        .. (horizontal and "ширины" or "высоты") .. " — нужно "
        .. tostring(round(used + gaps)) .. ", доступно " .. tostring(round(mainAvailable))
    )
    free = 0
  end
  if weight == 0 then
    free = 0
  end

  -- Остаток делим целыми числами и отдаём хвост последнему flex-ребёнку:
  -- иначе накапливается дробная погрешность и колонки съезжают на пиксель.
  local distributed, lastFlex = 0, nil
  for index, kid in ipairs(kids) do
    local spec = mainSpec(kid, horizontal)
    if spec ~= nil and spec.kind == "flex" then
      lastFlex = index
    end
  end
  for index, kid in ipairs(kids) do
    local spec = mainSpec(kid, horizontal)
    if spec ~= nil and spec.kind == "flex" then
      if index == lastFlex then
        mains[index] = math.max(0, free - distributed)
      else
        local share = math.floor(free * spec.weight / weight)
        mains[index] = math.max(0, share)
        distributed = distributed + mains[index]
      end
    end
  end

  -- Если flex-детей нет, вдоль оси остаётся зазор — его распределяет align
  -- (ровно как childAlignment в TTS), иначе блок молча прижимался бы к началу.
  local occupied = gaps
  for index = 1, #kids do
    occupied = occupied + (mains[index] or 0)
  end
  local mainFactor, crossFactor = alignFactors(
    alignment(node.attrs.align, "UpperLeft"), horizontal
  )
  local cursor = round(math.max(0, mainAvailable - occupied) * mainFactor)

  for index, kid in ipairs(kids) do
    local main = mains[index]
    local crossIntrinsic = kid.intrinsicH
    if horizontal == false then
      crossIntrinsic = kid.intrinsicW
    end
    local cross = resolveSize(crossSpec(kid, horizontal), crossAvailable, crossIntrinsic, true)
    local crossOffset = round(math.max(0, crossAvailable - cross) * crossFactor)

    if horizontal then
      arrange(kid, main, cross, originX + cursor, originY + crossOffset)
    else
      arrange(kid, cross, main, originX + crossOffset, originY + cursor)
    end
    cursor = cursor + main + node.gap
  end
end

-- Без потока: каждый ребёнок сам решает, куда прижаться (`at`), и по умолчанию
-- занимает всю внутреннюю область. Tак рисуются подложки и оверлеи.
--
-- Tонкость, из-за которой шапка раньше и разъезжалась: TTS считает
-- rectAlignment от ПОЛНОГО прямоугольника родителя и ничего не знает ни про
-- padding, ни про то, где мы хотим видеть элемент. Поэтому разницу между
-- посчитанной позицией и той, куда TTS поставит элемент сам, дописываем
-- offsetXY. В итоге дамп геометрии и картинка в игре — одно и то же.
local function arrangeStack(node, kids, innerW, innerH, originX, originY)
  for _, kid in ipairs(kids) do
    local width = resolveSize(kid.specW, innerW, kid.intrinsicW, true)
    local height = resolveSize(kid.specH, innerH, kid.intrinsicH, true)
    local place = alignment(kid.attrs.at, "MiddleCenter")
    local vertical, horizontal = place:match("^(%a-)(Left)$")
    if vertical == nil then
      vertical, horizontal = place:match("^(%a-)(Center)$")
    end
    if vertical == nil then
      vertical, horizontal = place:match("^(%a-)(Right)$")
    end

    local x, ttsX
    if horizontal == "Left" then
      x, ttsX = originX, node.x
    elseif horizontal == "Right" then
      x, ttsX = originX + innerW - width, node.x + node.w - width
    else
      x, ttsX = originX + round((innerW - width) / 2), node.x + round((node.w - width) / 2)
    end

    local y, ttsY
    if vertical == "Upper" then
      y, ttsY = originY, node.y
    elseif vertical == "Lower" then
      y, ttsY = originY + innerH - height, node.y + node.h - height
    else
      y, ttsY = originY + round((innerH - height) / 2), node.y + round((node.h - height) / 2)
    end

    -- <Anchor x y> — сдвиг от прижатого края, y растёт вниз (в TTS наоборот,
    -- инвертирование живёт в emit).
    if kid.tag == "Anchor" then
      x = x + (tonumber(kid.attrs.x) or 0)
      y = y + (tonumber(kid.attrs.y) or 0)
    end

    kid.placement = place
    kid.shiftX = x - ttsX
    kid.shiftY = y - ttsY

    arrange(kid, width, height, x, y)
  end
end

function arrange(node, width, height, x, y)
  node.w, node.h = round(width), round(height)
  node.x, node.y = round(x), round(y)

  local kids = elements(node)
  if #kids == 0 then
    return
  end

  local innerW = node.w - node.pad[1] - node.pad[2]
  local innerH = node.h - node.pad[3] - node.pad[4]
  local originX = node.x + node.pad[1]
  local originY = node.y + node.pad[3]

  if node.flow == "x" then
    arrangeFlow(node, kids, true, innerW, innerH, originX, originY)
  elseif node.flow == "y" then
    arrangeFlow(node, kids, false, innerW, innerH, originX, originY)
  elseif node.flow == "scroll" then
    -- Окно прокрутки: поперёк сужаемся на скроллбар, вдоль берём максимум из
    -- размера окна и содержимого — содержимое имеет право быть длиннее.
    local contentW = innerW - Layout.metrics.scrollbar
    local contentH = math.max(innerH, node.contentH)
    node.contentBox = { w = contentW, h = contentH }
    arrangeFlow(node, kids, false, contentW, contentH, originX, originY)
  else
    arrangeStack(node, kids, innerW, innerH, originX, originY)
  end
end

------------------------------------------------------------------ сериализация --

local SKIP_ATTRS = {
  width = true, height = true, padding = true, gap = true, align = true,
  at = true, x = true, y = true, color = true,
}

local function attrString(node, extra)
  local parts = {}
  for _, key in ipairs(extra) do
    table.insert(parts, key[1] .. '="' .. tostring(key[2]) .. '"')
  end
  for _, key in ipairs(node.order) do
    if not SKIP_ATTRS[key] then
      table.insert(parts, key .. '="' .. node.attrs[key] .. '"')
    end
  end
  if #parts == 0 then
    return ""
  end
  return " " .. table.concat(parts, " ")
end

local emit

local function emitKids(node, out)
  for _, kid in ipairs(node.kids) do
    if kid.text ~= nil then
      table.insert(out, kid.text)
    else
      emit(kid, out)
    end
  end
end

-- Автоподбор кегля включаем только если его ЯВНО попросили атрибутом
-- resizeTextForBestFit="true". Принудительное сжатие по умолчанию в ряде случаев
-- уродует кириллицу в TTS (визуально «ломаные» буквы).
local function textFit(node, extra)
  if tostring(node.attrs.resizeTextForBestFit) ~= "true" then
    return
  end
  local fontSize = tonumber(node.attrs.fontSize) or 14
  local minSize = math.max(6, math.floor(fontSize * Layout.metrics.minFontRatio))
  table.insert(extra, { "resizeTextForBestFit", "true" })
  table.insert(extra, { "resizeTextMinSize", minSize })
  table.insert(extra, { "resizeTextMaxSize", math.floor(fontSize) })
end

local TRANSPARENT = "rgba(0,0,0,0)"

-- Группа раскладки эмитится ровно в одной конфигурации: все четыре
-- child*-флага false. Размеры детей уже посчитаны, поэтому переопределять их
-- группе нечем — та самая «третья конфигурация», которой раньше не бывало,
-- теперь просто не нужна.
local function emitGroup(node, out, tag, defaultAlign)
  local pad = node.pad
  table.insert(out, "<" .. tag)
  table.insert(out, ' padding="' .. table.concat({ pad[1], pad[2], pad[3], pad[4] }, " ") .. '"')
  table.insert(out, ' spacing="' .. tostring(node.gap) .. '"')
  table.insert(out, ' childAlignment="' .. alignment(node.attrs.align, defaultAlign) .. '"')
  table.insert(out, ' childControlWidth="false" childControlHeight="false"')
  table.insert(out, ' childForceExpandWidth="false" childForceExpandHeight="false">')
  emitKids(node, out)
  table.insert(out, "</" .. tag .. ">")
end

local function emitVerbatim(node, out)
  local parts = {}
  for _, key in ipairs(node.order) do
    table.insert(parts, key .. '="' .. node.attrs[key] .. '"')
  end
  local attrs = (#parts > 0) and (" " .. table.concat(parts, " ")) or ""
  if #node.kids == 0 then
    table.insert(out, "<" .. node.tag .. attrs .. " />")
    return
  end
  table.insert(out, "<" .. node.tag .. attrs .. ">")
  for _, kid in ipairs(node.kids) do
    if kid.text ~= nil then
      table.insert(out, kid.text)
    else
      emitVerbatim(kid, out)
    end
  end
  table.insert(out, "</" .. node.tag .. ">")
end

function emit(node, out)
  local tag = node.tag

  if tag == "#root" then
    emitKids(node, out)
    return
  end

  if node.verbatim then
    emitVerbatim(node, out)
    return
  end

  local extra = {}
  -- Корневой блок на весь экран размер НЕ получает: Panel без width/height
  -- растягивается по холсту TTS, а зашитые 1920x1080 разъехались бы с реальным
  -- разрешением (и рейка уехала бы от края экрана).
  if not node.rootFill then
    table.insert(extra, { "width", node.w })
    table.insert(extra, { "height", node.h })
  end

  -- Позиция нужна только детям блоков без потока: внутри Row/Col положение
  -- задаёт группа, и лишний атрибут только путал бы.
  -- Text элементы внутри Box: они должны растягиваться на весь размер родителя,
  -- поэтому rectAlignment не добавляем для них (вызывает обрезание при малой высоте).
  if node.placement ~= nil and node.tag ~= "Text" then
    table.insert(extra, { "rectAlignment", node.placement })
    if node.shiftX ~= 0 or node.shiftY ~= 0 then
      -- В TTS положительный y направлен ВВЕРХ; в разметке y считается вниз,
      -- как во всех остальных системах координат. Инвертируем здесь один раз.
      table.insert(extra, { "offsetXY", tostring(node.shiftX) .. " " .. tostring(-node.shiftY) })
    end
  end

  if node.primitive then
    -- Корневому блоку на весь экран цвет не дописываем: в игре это прозрачная
    -- подложка поверх стола. И raycastTarget="false" ему обязателен — по
    -- умолчанию он true, то есть прозрачная панель на весь экран съедала бы
    -- клики по столу.
    if node.attrs.color ~= nil then
      table.insert(extra, { "color", node.attrs.color })
    elseif not node.rootFill then
      table.insert(extra, { "color", TRANSPARENT })
    end
    if node.rootFill and node.attrs.raycastTarget == nil then
      table.insert(extra, { "raycastTarget", "false" })
    end

    if tag == "Scroll" then
      table.insert(out, "<VerticalScrollView" .. attrString(node, extra) .. ">")
      table.insert(out, "<VerticalLayout")
      local pad = node.pad
      table.insert(out, ' padding="' .. table.concat({ pad[1], pad[2], pad[3], pad[4] }, " ") .. '"')
      table.insert(out, ' spacing="' .. tostring(node.gap) .. '"')
      table.insert(out, ' childAlignment="' .. alignment(node.attrs.align, "UpperLeft") .. '"')
      table.insert(out, ' childControlWidth="false" childControlHeight="false"')
      table.insert(out, ' childForceExpandWidth="false" childForceExpandHeight="false">')
      emitKids(node, out)
      table.insert(out, "</VerticalLayout></VerticalScrollView>")
      return
    end

    table.insert(out, "<Panel" .. attrString(node, extra) .. ">")
    if node.flow == "x" then
      emitGroup(node, out, "HorizontalLayout", "UpperLeft")
    elseif node.flow == "y" then
      emitGroup(node, out, "VerticalLayout", "UpperLeft")
    else
      emitKids(node, out)
    end
    table.insert(out, "</Panel>")
    return
  end

  -- Обычный тег TTS (Text, Button, InputField, ...): дописываем посчитанный
  -- размер, остальные атрибуты не трогаем.
  if node.attrs.color ~= nil then
    table.insert(extra, { "color", node.attrs.color })
  end
  if tag == "Text" then
    textFit(node, extra)
  end

  if #node.kids == 0 then
    table.insert(out, "<" .. tag .. attrString(node, extra) .. " />")
  else
    table.insert(out, "<" .. tag .. attrString(node, extra) .. ">")
    emitKids(node, out)
    table.insert(out, "</" .. tag .. ">")
  end
end

--------------------------------------------------------------------- API --

-- Дерево с посчитанной геометрией. Нужен и solve, и dump, и тестам.
function Layout.build(xml)
  Layout.problems = {}
  local root = parse(xml)
  prepare(root)
  measure(root)

  local kids = elements(root)
  for _, kid in ipairs(kids) do
    local width = resolveSize(kid.specW, Layout.screen.width, kid.intrinsicW, true)
    local height = resolveSize(kid.specH, Layout.screen.height, kid.intrinsicH, true)
    -- Верхний блок, объявленный fill/fill, — это «весь экран»: размер ему
    -- считаем по опорному холсту (чтобы посчитать детей), но в XML не пишем.
    if kid.primitive
      and kid.specW ~= nil and kid.specW.kind == "flex"
      and kid.specH ~= nil and kid.specH.kind == "flex"
    then
      kid.rootFill = true
    end
    arrange(kid, width, height, 0, 0)
  end
  root.w, root.h, root.x, root.y = Layout.screen.width, Layout.screen.height, 0, 0
  return root
end

function Layout.solve(xml)
  local root = Layout.build(xml)
  local out = {}
  emit(root, out)
  return table.concat(out)
end

-- Дамп посчитанной геометрии: «что реально получилось» одной портянкой.
-- Печатается и в консоли TTS (print(Layout.dump(xml))), и в тестах.
function Layout.dump(xml)
  local root = Layout.build(xml)
  local lines = {}

  local function walk(node, depth)
    for _, kid in ipairs(node.kids) do
      -- <Defaults> — таблица стилей, геометрии у него нет.
      if kid.text == nil and not kid.verbatim then
        local id = kid.attrs.id
        table.insert(lines, string.format(
          "%s%s%s  %dx%d @ %d,%d",
          string.rep("  ", depth),
          kid.tag,
          (id ~= nil and id ~= "") and ("#" .. id) or "",
          kid.w, kid.h, kid.x, kid.y
        ))
        walk(kid, depth + 1)
      end
    end
  end

  walk(root, 0)
  return table.concat(lines, "\n")
end

return Layout
