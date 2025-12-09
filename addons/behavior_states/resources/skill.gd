@tool
class_name Skill extends Resource

@export var icon: Texture2D
@export var components: Array[SkillComponent] = []

# ==================== FACADE PROPERTIES (Compatibility) ====================

var id: String:
	get:
		var c = get_component("Identity")
		return c.skill_name.to_snake_case() if c else "unknown_skill" # Fallback ID from name
var skill_name: String:
	get:
		var c = get_component("Identity")
		return c.skill_name if c else "New Skill"

var max_level: int:
	get:
		var c = get_component("Skill Level")
		return c.max_level if c else 1

var prerequisites: Array[Resource]:
	get:
		var c = get_component("Prerequisites")
		if c:
			return c.required_skills
		var empty: Array[Resource] = []
		return empty

var unlocks_states: Array[Resource]:
	get:
		var c = get_component("Unlock States")
		return c.states_to_unlock if c else []

func can_unlock(sheet: Resource, unlocked_ids: Array) -> bool:
	var c = get_component("Prerequisites")
	# Logic could be complex, for now assume True if check logic is in tree or here
	# Re-implementing check logic here or in component?
	# Component has data. Logic should be here or component.
	if c:
		for req_res in c.required_skills:
			# This implies req_res is a Skill Resource
			# To avoid cycle, we cast or assume
			if req_res.has_method("get_id"): # Checking ID
				# This is tricky without strict type.
				pass
	return true # Placeholder, SkillTree logic handles it?

# ==================== COMPONENT ACCESS ====================

func get_component(type_name: String) -> SkillComponent:
	for c in components:
		if c.get_component_name() == type_name:
			return c
	return null

func get_component_by_class(type: Variant) -> SkillComponent:
	for c in components:
		if is_instance_of(c, type):
			return c
	return null
