## ItemComponent — Base para Components que definem propriedades de Items.
##
## Items são compostos por múltiplos ItemComponents que definem
## identidade, stacking, durabilidade, consumo, equipamento, etc.
class_name ItemComponent extends ComponentBase

# ══════════════════════════════════════════════════════════════
# RUNTIME INTERFACE (Virtual — sobrescreva nas subclasses)
# ══════════════════════════════════════════════════════════════

## Chamado quando o item é usado (consumíveis)
func on_use(ctx: ItemContext) -> void:
	pass

## Chamado quando o item é equipado
func on_equip(ctx: ItemContext) -> void:
	pass

## Chamado quando o item é desequipado
func on_unequip(ctx: ItemContext) -> void:
	pass

# ══════════════════════════════════════════════════════════════
# EDITOR INTERFACE (Override)
# ══════════════════════════════════════════════════════════════

static func _get_component_category() -> String:
	return "Item"
