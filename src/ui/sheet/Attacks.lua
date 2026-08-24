-- Атаки. Количество строк зависит от данных, перечислить их в разметке нельзя —
-- вид строки лежит в layout/AttackRow.xml (просмотр) и AttackEditRow.xml
-- (визард), а цикл здесь. В визарде строк на одну больше: заполнили пустую —
-- появилась новая атака.
local Common = require("ui.sheet.Common")
local Component = require("ui.Component")
local Field = require("ui.sheet.Field")
local Label = require("ui.components.Label")
local Templates = require("ui.generated.Templates")

local Attacks = {}

Attacks.defaults = {}

function Attacks.render()
  local attacks = Common.character().attacks or {}
  local rows = {}

  if Common.isWizard() then
    for index = 1, #attacks + 1 do
      table.insert(rows, Component.render(Templates.AttackEditRow, {
        HEIGHT = 28,
        NAME = Field.render({ name = "field_attack_" .. index .. "_name", height = "fill" }),
        BONUS = Field.render({ name = "field_attack_" .. index .. "_bonus", height = "fill" }),
        DAMAGE = Field.render({ name = "field_attack_" .. index .. "_damage", height = "fill" }),
      }))
    end
    return Component.join(rows)
  end

  if #attacks == 0 then
    return Label.render({ text = "—", fontSize = 13, color = "textMuted" })
  end
  for _, attack in ipairs(attacks) do
    table.insert(rows, Component.render(Templates.AttackRow, {
      NAME = Component.escape(attack.name),
      BONUS = Component.escape(attack.atkBonus),
      DAMAGE = Component.escape(attack.damage),
    }))
  end
  return Component.join(rows)
end

return Attacks
