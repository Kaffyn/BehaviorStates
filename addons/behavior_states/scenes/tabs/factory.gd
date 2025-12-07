@tool
## Fábrica de Recursos (Factory Wizard).
##
## Interface para criação rápida de novos recursos de comportamento (State, Manifest, etc).
extends MarginContainer

# Map of Display Name -> Class Name (String)
const TYPES = {
	"State (BehaviorUnit)": "State",
	"Compose (Manifest)": "Compose",
	"Item (ItemData)": "Item",
	"CharacterSheet": "CharacterSheet",
	"Skill (Unlockable)": "Skill"
}

@onready var file_dialog: FileDialog = $FileDialog

var _pending_type: String = ""

func _on_create_pressed(type_name: String) -> void:
	_pending_type = TYPES[type_name]
	file_dialog.filters = ["*.tres ; Resources"]
	file_dialog.current_file = "new_" + _pending_type.to_lower() + ".tres"
	file_dialog.popup_centered_ratio(0.6)

func _on_file_dialog_file_selected(path: String) -> void:
	if _pending_type.is_empty():
		return
		
	var script_path = "res://addons/behavior_states/resources/" + _pending_type.to_snake_case() + ".gd"
	
	# We need to instantiate the custom resource. 
	# Since these are custom classes, we can try matching by class_name or loading the script.
	# But class_name instantiation via ClassDB only works if registered.
	# Safer to load the script and .new()
	
	if ResourceLoader.exists(script_path):
		var script = load(script_path)
		if script and script is GDScript:
			var res = script.new()
			# Save it
			var err = ResourceSaver.save(res, path)
			if err == OK:
				print("Created " + _pending_type + " at " + path)
				EditorInterface.edit_resource(res)
				# Ideally refresh library too
			else:
				printerr("Error saving resource: ", err)
	else:
		printerr("Script not found for type: " + _pending_type)
		
	_pending_type = ""
