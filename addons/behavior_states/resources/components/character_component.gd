## CharacterComponent — Base para Components de CharacterSheet.
##
## CharacterSheets são compostos por CharacterComponents que definem
## stats vitais, atributos, progressão, etc.
## Diferente de outros Components, CharacterComponents são dados estáticos
## sem hooks de runtime.
class_name CharacterComponent extends ComponentBase

# ══════════════════════════════════════════════════════════════
# EDITOR INTERFACE (Override)
# ══════════════════════════════════════════════════════════════

static func _get_component_category() -> String:
	return "Character"

# ══════════════════════════════════════════════════════════════
# DATA INTERFACE (Virtual — sobrescreva nas subclasses)
# ══════════════════════════════════════════════════════════════

## Retorna os valores de stat deste component
## Ex: { "max_health": 100, "max_stamina": 100.0 }
func get_stats() -> Dictionary:
	return {}

## Aplica modificadores a um CharacterSheet
func apply_to(sheet: Resource) -> void:
	var stats = get_stats()
	for stat_name in stats:
		if stat_name in sheet:
			sheet.set(stat_name, stats[stat_name])
