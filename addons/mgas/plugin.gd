@tool
extends EditorPlugin

var bottom_panel_scene = preload("res://addons/mgas/editor/workbench_panel.tscn")
var bottom_panel_instance

func _enter_tree():
    # Load and add the bottom panel
    bottom_panel_instance = bottom_panel_scene.instantiate()
    add_control_to_bottom_panel(bottom_panel_instance, "MGAS Workbench")
    
    # Register Project Settings if needed (Tags)
    if not ProjectSettings.has_setting("mgas/general/tag_config_path"):
        ProjectSettings.set_setting("mgas/general/tag_config_path", "res://gameplay_tags.json")
        ProjectSettings.set_initial_value("mgas/general/tag_config_path", "res://gameplay_tags.json")

func _exit_tree():
    if bottom_panel_instance:
        remove_control_from_bottom_panel(bottom_panel_instance)
        bottom_panel_instance.queue_free()
