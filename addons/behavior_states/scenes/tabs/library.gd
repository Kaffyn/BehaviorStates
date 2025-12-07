@tool
## Biblioteca de Ativos (Asset Library).
##
## Gerencia, lista e filtra recursos de comportamento (.tres) do projeto.
extends MarginContainer

@onready var search_edit: LineEdit = $VBoxContainer/HBoxContainer/SearchEdit
@onready var asset_list: ItemList = $VBoxContainer/AssetList

var _all_assets: Array[String] = []

func _ready() -> void:
    if search_edit:
        search_edit.text_changed.connect(_on_search_text_changed)
    if asset_list:
        asset_list.item_activated.connect(_on_item_activated)
    
    refresh_assets()

func refresh_assets() -> void:
    _all_assets.clear()
    _scan_directory("res://")
    _update_list()

func _scan_directory(path: String) -> void:
    var dir = DirAccess.open(path)
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if dir.current_is_dir():
                if file_name != "." and file_name != ".." and file_name != ".godot":
                    _scan_directory(path + "/" + file_name)
            else:
                if file_name.ends_with(".tres"):
                    _all_assets.append(path + "/" + file_name)
            file_name = dir.get_next()

func _update_list(filter: String = "") -> void:
    if not asset_list:
        return
        
    asset_list.clear()
    for path in _all_assets:
        if filter.is_empty() or filter.to_lower() in path.to_lower():
            asset_list.add_item(path)
            asset_list.set_item_tooltip(asset_list.get_item_count() - 1, path)

func _on_search_text_changed(new_text: String) -> void:
    _update_list(new_text)

func _on_item_activated(index: int) -> void:
    var path = asset_list.get_item_text(index)
    if ResourceLoader.exists(path):
        var res = load(path)
        EditorInterface.edit_resource(res)

func _on_refresh_pressed() -> void:
    refresh_assets()
