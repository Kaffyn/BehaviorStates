@tool
## Depurador em Tempo Real (Live Debugger).
##
## Monitora estados ativos e histórico de decisões da Machine.
extends MarginContainer

@onready var state_tree: Tree = $VBoxContainer/HSplitContainer/StateTree
@onready var log_output: RichTextLabel = $VBoxContainer/HSplitContainer/LogOutput

func _ready() -> void:
    if state_tree:
        state_tree.set_column_title(0, "Node")
        state_tree.set_column_title(1, "State")
    
    log_message("Debugger initialized. Waiting for connection...")

func _on_connect_pressed() -> void:
    log_message("[color=yellow]Connecting to active session...[/color]")
    # Placeholder for EditorDebuggerPlugin connection
    await get_tree().create_timer(1.0).timeout
    log_message("[color=red]No active game session found (Protocol not implemented).[/color]")

func _on_clear_pressed() -> void:
    if log_output:
        log_output.clear()

func log_message(msg: String) -> void:
    if log_output:
        log_output.append_text(msg + "\n")
