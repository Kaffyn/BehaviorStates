## CooldownComponent — Define tempo de recarga para reuso do State.
@tool
class_name CooldownComponent extends StateComponent

@export var cooldown: float = 0.0

const RUNTIME_KEY := "cooldown"

func on_enter(ctx: StateContext) -> void:
	# Register cooldown in Behavior/Blackboard so it persists after state exit
	# For simplicity, we assume Behavior has a cooldown manager or we use blackboard.
	# We'll use blackboard["cooldowns"] dictionary.
	if cooldown <= 0:
		return
		
	var cooldowns = ctx.blackboard.get_or_add("cooldowns", {})
	# Key is state resource path or unique ID
	var key = ctx.state.resource_path
	cooldowns[key] = Time.get_ticks_msec() / 1000.0 + cooldown

static func is_on_cooldown(ctx: StateContext, state: Resource) -> bool:
	var cooldowns = ctx.blackboard.get("cooldowns", {})
	var key = state.resource_path
	if not cooldowns.has(key):
		return false
	
	var ready_time = cooldowns[key]
	return (Time.get_ticks_msec() / 1000.0) < ready_time

static func _get_component_name() -> String:
	return "Cooldown"

static func _get_component_color() -> Color:
	return Color("#3b82f6")

static func _get_component_fields() -> Array:
	return [
		{"name": "cooldown", "type": "float", "default": 0.0}
	]
