@tool
## Configuração Global do BehaviorStates (Editor Preferences).
##
## Armazena preferências do editor, cores de visualização e caminhos padrão para a Factory.
class_name BehaviorStatesConfig extends Resource

@export_group("Paths")
## Caminho padrão para salvar novos Behaviors criados pela Factory.
@export_dir var default_behaviors_path: String = "res://entities/behaviors"
## Caminho padrão para salvar novos Manifestos.
@export_dir var default_manifests_path: String = "res://resources/manifests"

@export_group("Visuals")
## Cor usada para nós de Estado no GraphEdit.
@export var state_node_color: Color = Color.CORNFLOWER_BLUE
## Cor usada para nós de Transição/Connections.
@export var transition_color: Color = Color.WHITE

@export_group("Debug")
## Cor dos logs de comportamento no console.
@export var log_color: Color = Color.ORANGE
