@tool
extends VBoxContainer

@onready var tree = $Tree

func _ready():
    # Only scan if visible to save performance
    connect("visibility_changed", _on_visibility_changed)
    _on_visibility_changed()

func _on_visibility_changed():
    if visible:
        refresh_library()

func refresh_library():
    tree.clear()
    var root = tree.create_item()
    root.set_text(0, "Abilitites")
    
    var files = _scan_dir("res://")
    for file_path in files:
        if file_path.ends_with(".tres"):
            var res = load(file_path)
            if res and res.get_class() == "MachiGameplayAbility":
                var item = tree.create_item(root)
                item.set_text(0, file_path.get_file())
                item.set_tooltip_text(0, file_path)

func _scan_dir(path: String) -> Array:
    var found = []
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir():
                if file_name != "." and file_name != ".." and not file_name.begins_with("."):
                    found.append_array(_scan_dir(path.path_join(file_name)))
            else:
                found.append(path.path_join(file_name))
            file_name = dir.get_next()
    return found
