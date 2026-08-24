-- Портрет на листе: силуэт (если URL задан) или первая буква имени.
-- В визарде — два поля для URL (силуэт и портрет).
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Templates = require("ui.generated.Templates")
local Field = require("ui.sheet.Field")

local PortraitLetter = {}

PortraitLetter.defaults = {
  fontSize = 48,
  color = "goldBright",
}

function PortraitLetter.render(props)
  local p = Component.props(PortraitLetter.defaults, props)
  local character = Common.character()
  local silhouetteUrl = character.silhouette or ""

  -- Буква-заглушка через шаблон
  local name = tostring(character.name or "?")
  local letterXml = Component.render(Templates.PortraitLetter, {
    LETTER = Component.escape(name:match("^[\1-\127\194-\244][\128-\191]*") or "?"),
    FONT_SIZE = p.fontSize,
    COLOR = p.color,
  })

  -- В view: силуэт или буква
  local content = letterXml
  if silhouetteUrl ~= "" then
    content = '<Image image="silhouette_' .. character.id .. '" preserveAspect="true"/>'
  end

  if Common.isWizard() then
    return '<Col width="fill" height="fill" gap="4" align="topleft">'
      .. '<Box width="fill" height="fill">' .. content .. '</Box>'
      .. '<Box width="fill" height="22">'
      .. Field.render({
        name = "field_silhouette",
        fontSize = 8,
        color = "textMuted",
        alignment = "MiddleLeft",
        height = "fill",
        placeholder = "URL силуэта",
      })
      .. '</Box>'
      .. '<Box width="fill" height="22">'
      .. Field.render({
        name = "field_portrait",
        fontSize = 8,
        color = "textMuted",
        alignment = "MiddleLeft",
        height = "fill",
        placeholder = "URL портрета",
      })
      .. '</Box>'
      .. '</Col>'
  end

  return content
end

return PortraitLetter
