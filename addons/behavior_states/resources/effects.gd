@tool
## Effects - Modificadores e Status Effects
##
## Resource que define efeitos temporários, instantâneos ou permanentes.
## Usado por Items (ao consumir/equipar), Skills (passivas/ativas), e States (buffs/debuffs).
class_name Effects extends Resource

enum EffectType { INSTANT, TEMPORARY, PERMANENT }
enum StatusType { NONE, POISON, BURN, FREEZE, STUN, SLOW, HASTE, REGEN, BLEED }

# ============= IDENTITY =============
@export_group("Identity")
@export var id: String = ""
@export var name: String = "Effect"
@export_multiline var description: String = ""
@export var icon: Texture2D

# ============= TYPE & DURATION =============
@export_group("Type & Duration")
## Tipo do efeito: INSTANT (aplica uma vez), TEMPORARY (duração), PERMANENT (até remoção).
@export var effect_type: EffectType = EffectType.INSTANT
## Duração em segundos (apenas para TEMPORARY).
@export var duration: float = 0.0
## Se true, o efeito pode ser empilhado múltiplas vezes.
@export var stackable: bool = false
## Número máximo de stacks.
@export var max_stacks: int = 1

# ============= STAT MODIFIERS =============
@export_group("Stat Modifiers")
## Modificadores de stats aplicados. Ex: {"max_health": 50, "speed": 1.2, "strength": -5}
## Valores inteiros são adicionados, valores float são multiplicadores.
@export var stat_modifiers: Dictionary = {}

# ============= STATUS EFFECT =============
@export_group("Status Effect")
## Status especial aplicado (Poison, Burn, etc.)
@export var status_type: StatusType = StatusType.NONE
## Dano por tick (para POISON, BURN, BLEED).
@export var damage_per_tick: int = 0
## Intervalo entre ticks em segundos.
@export var tick_interval: float = 1.0
## Cura por tick (para REGEN).
@export var heal_per_tick: int = 0

# ============= VISUAL =============
@export_group("Visual Feedback")
## Cena de VFX instanciada no alvo.
@export var vfx_scene: PackedScene
## Cor de tint aplicada ao sprite do alvo.
@export var tint_color: Color = Color.WHITE
## Som tocado ao aplicar.
@export var apply_sound: AudioStream

# ============= LOGIC =============

## Aplica o efeito a um CharacterSheet.
## Retorna true se aplicado com sucesso.
func apply(sheet: Resource) -> bool:
	if not sheet:
		return false
	
	# Apply stat modifiers
	for stat in stat_modifiers:
		if stat in sheet:
			var modifier = stat_modifiers[stat]
			var current = sheet.get(stat)
			if modifier is float and modifier != 0.0:
				# Multiplicative modifier
				sheet.set(stat, current * modifier)
			elif modifier is int:
				# Additive modifier
				sheet.set(stat, current + modifier)
	
	return true

## Remove o efeito de um CharacterSheet (reverte modificadores).
func remove(sheet: Resource) -> bool:
	if not sheet:
		return false
	
	# Revert stat modifiers
	for stat in stat_modifiers:
		if stat in sheet:
			var modifier = stat_modifiers[stat]
			var current = sheet.get(stat)
			if modifier is float and modifier != 0.0:
				# Revert multiplicative
				sheet.set(stat, current / modifier)
			elif modifier is int:
				# Revert additive
				sheet.set(stat, current - modifier)
	
	return true

## Processa um tick do efeito (para efeitos over-time).
## Retorna o dano/cura causado neste tick.
func process_tick(sheet: Resource) -> int:
	if not sheet:
		return 0
	
	match status_type:
		StatusType.POISON, StatusType.BURN, StatusType.BLEED:
			if "current_health" in sheet:
				sheet.current_health = max(0, sheet.current_health - damage_per_tick)
			return -damage_per_tick
		StatusType.REGEN:
			if "current_health" in sheet and "max_health" in sheet:
				sheet.current_health = min(sheet.max_health, sheet.current_health + heal_per_tick)
			return heal_per_tick
	
	return 0

## Retorna uma descrição formatada do efeito.
func get_formatted_description() -> String:
	var parts: Array = []
	
	for stat in stat_modifiers:
		var mod = stat_modifiers[stat]
		var sign = "+" if mod > 0 else ""
		if mod is float:
			parts.append("%s%d%% %s" % [sign, int((mod - 1.0) * 100), stat])
		else:
			parts.append("%s%d %s" % [sign, mod, stat])
	
	if status_type != StatusType.NONE:
		parts.append(StatusType.keys()[status_type])
	
	if effect_type == EffectType.TEMPORARY and duration > 0:
		parts.append("(%.1fs)" % duration)
	
	return " | ".join(parts) if parts.size() > 0 else description
