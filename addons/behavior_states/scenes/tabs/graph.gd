@tool
## Visualizador de Comportamento (Graph Viewer).
##
## Exibe os estados de um BehaviorManifest como nós em um grafo visual.
extends GraphEdit

@onready var file_dialog: FileDialog = $FileDialog

var current_manifest: Compose

func _ready() -> void:
    # Setup graph behavior
    right_disconnects = true
    add_valid_connection_type(0, 0) # Allow any connection for visualization
    
func _on_load_pressed() -> void:
    file_dialog.popup_centered_ratio(0.6)

func _on_file_dialog_file_selected(path: String) -> void:
    var res = load(path)
    if res and res is Compose:
        load_manifest(res)
    else:
        printerr("File is not a Compose (Manifest) resource.")

func load_manifest(manifest: Compose) -> void:
    current_manifest = manifest
    clear_connections()
    
    # Remove existing nodes (except internal ones if any)
    for child in get_children():
        if child is GraphNode:
            remove_child(child)
            child.queue_free()
            
    # Visualize content
    # For now, just create a node for the Manifest and generic nodes for lists
    # Since specific properties like move_rules map specific keys to arrays of states.
    
    var root_node = _create_node("Manifest: " + manifest.resource_path.get_file(), Vector2(50, 50))
    
    var y_offset = 0
    # Visualize Move Rules (Bucket)
    if not manifest.move_rules.is_empty():
        var bucket_node = _create_node("Move Rules", Vector2(300, 50 + y_offset))
        connect_node(root_node.name, 0, bucket_node.name, 0)
        y_offset += 150
        
    # Visualize Attack Rules
    if not manifest.attack_rules.is_empty():
        var bucket_node = _create_node("Attack Rules", Vector2(300, 50 + y_offset))
        connect_node(root_node.name, 0, bucket_node.name, 0)
        y_offset += 150

func _create_node(title: String, position: Vector2) -> GraphNode:
    var node = GraphNode.new()
    node.title = title
    node.position_offset = position
    node.resizable = true
    node.set_slot(0, true, 0, Color.WHITE, true, 0, Color.WHITE)
    add_child(node)
    
    var label = Label.new()
    label.text = "Content"
    node.add_child(label)
    
    return node
