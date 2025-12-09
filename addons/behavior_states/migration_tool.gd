@tool
extends SceneTree

# Migration Tool (CLI Version)
# Iterates over all .tres files in the project
# Checks for legacy data in State and Item resources
# Migrates data to Components

# Preload classes to avoid "Identifier not found" if Godot hasn't scanned yet
const CooldownComponentScript = preload("res://addons/behavior_states/resources/components/state/cooldown_component.gd")
const DurationComponentScript = preload("res://addons/behavior_states/resources/components/state/duration_component.gd")
const HitboxComponentScript = preload("res://addons/behavior_states/resources/components/state/hitbox_component.gd")
const ProjectileComponentScript = preload("res://addons/behavior_states/resources/components/state/projectile_component.gd")
const CostComponentScript = preload("res://addons/behavior_states/resources/components/state/cost_component.gd")
const ChargedComponentScript = preload("res://addons/behavior_states/resources/components/state/charged_component.gd")

const IdentityItemComponentScript = preload("res://addons/behavior_states/resources/components/item/identity_component.gd")
const StackingItemComponentScript = preload("res://addons/behavior_states/resources/components/item/stacking_component.gd")

func _init() -> void:
	print("Starting Migration...")
	var dir = DirAccess.open("res://entities") # Adjust root path if needed
	if dir:
		_process_dir(dir)
	
	# Also check root data folder if exists
	dir = DirAccess.open("res://addons/behavior_states/data")
	if dir:
		_process_dir(dir)
		
	print("Migration Complete.")
	quit()

func _process_dir(dir: DirAccess) -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			if file_name != "." and file_name != "..":
				var subdir = DirAccess.open(dir.get_current_dir() + "/" + file_name)
				if subdir:
					_process_dir(subdir)
		else:
			if file_name.ends_with(".tres"):
				_migrate_resource(dir.get_current_dir() + "/" + file_name)
		file_name = dir.get_next()

func _migrate_resource(path: String) -> void:
	# Use load() instead of ResourceLoader to get the resource
	var res = load(path)
	if not res:
		return
		
	var modified = false
	
	if res is State:
		modified = _migrate_state(res, path)
	elif res is Item:
		modified = _migrate_item(res)
		
	if modified:
		print("Migrated: ", path)
		# Force save to persist component changes
		ResourceSaver.save(res)

func _migrate_state(state: State, path: String) -> bool:
	var modified = false
	
	# 1. Damage / Projectile -> ProjectileComponent or HitboxComponent
	if state.projectile_scene:
		if not state.get_component("Projectile"):
			var comp = ProjectileComponentScript.new()
			comp.projectile_scene = state.projectile_scene
			comp.projectile_speed = state.projectile_speed
			comp.projectile_count = state.projectile_count
			comp.spawn_offset = state.spawn_offset
			if state.damage > 0:
				comp.damage_multiplier = 1.0 
			state.components.append(comp)
			modified = true
	elif state.damage > 0:
		# Melee Hitbox
		if not state.get_component("Hitbox"):
			var comp = HitboxComponentScript.new()
			# Heuristic: multiplier = legacy_damage / 10.0
			comp.damage_multiplier = float(state.damage) / 10.0
			state.components.append(comp)
			modified = true
			
	# CORE RESTORATION: Ensure legacy dicts are secure (even if not strictly moving)
	# If legacy dict is populated but core one isn't, copy it?
	# state.entry_requirements is now defined as @export in the main group.
	# If the file loaded legacy data into it (because name matched), it's already there!
	# But if legacy was named something different, we might need manual copy.
	# Checking legacy definition: @export var entry_requirements: Dictionary = {}
	# Checking NEW definition: @export var entry_requirements: Dictionary = {}
	# Same name! Godot should have loaded it directly into the new slot.
	# We just need to save to confirm it stays there.
	
	# 2. Cooldown -> CooldownComponent
	if state.cooldown > 0:
		if not state.get_component("Cooldown"):
			var comp = CooldownComponentScript.new()
			comp.cooldown = state.cooldown
			state.components.append(comp)
			modified = true
			
	# 3. Duration -> DurationComponent
	if state.duration > 0:
		if not state.get_component("Duration"):
			var comp = DurationComponentScript.new()
			comp.duration = state.duration
			state.components.append(comp)
			modified = true

	# 4. Charged -> ChargedComponent
	if state.is_charged:
		if not state.get_component("Charged"):
			var comp = ChargedComponentScript.new()
			comp.min_charge_time = state.min_charge_time
			comp.max_charge_time = state.max_charge_time
			state.components.append(comp)
			modified = true

	# 5. Cost -> CostComponent
	if state.cost_amount > 0:
		if not state.get_component("Cost"):
			var comp = CostComponentScript.new()
			comp.cost_amount = float(state.cost_amount)
			comp.cost_type = state.cost_type # Check compatibility of Enum
			state.components.append(comp)
			modified = true

	return modified

func _migrate_item(item: Item) -> bool:
	var modified = false
	
	# Identity -> Kept on Item for compatibility? 
	# User wants less separation. Let's keep Name/Descr/Icon on Item facade but also sync to component if needed.
	# For now, let's keep the IdentityComponent creation but maybe not force it if the user wants simple items.
	# Actually, the user complaint was specific to State. Items having components is usually fine.
	
	if not item.get_component("Identity"):
		var comp = IdentityItemComponentScript.new()
		# Only migrate if we have legacy data
		if item.id != "": comp.id = item.id
		if item.name != "": comp.display_name = item.name 
		if item.description != "": comp.description = item.description
		comp.icon = item.icon
		item.components.append(comp)
		modified = true
		
	# Stacking
	if item.stackable:
		if not item.get_component("Stacking"):
			var comp = StackingItemComponentScript.new()
			comp.stackable = true
			comp.max_stack = item.max_stack
			item.components.append(comp)
			modified = true

	return modified
