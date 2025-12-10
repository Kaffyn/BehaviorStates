@tool
extends VBoxContainer

var current_asc = null
@onready var label = $Label

func _process(delta):
    if not visible: return
    
    var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
    if selected_nodes.size() == 1:
        var node = selected_nodes[0]
        # Duck typing check for MachiASC
        if node.get_class() == "MachiAbilitySystemComponent" or node.has_method("try_activate_ability"):
            if current_asc != node:
                _select_asc(node)
        else:
            current_asc = null
            label.text = "Select a Node with MachiASC"
            
    if current_asc:
        # Update UI loop
        pass

func _select_asc(node):
    current_asc = node
    label.text = "Debugging: " + node.name
    # Connect signals if needed
