@tool
## Visualizador de Documentação (Grimório).
##
## Carrega e exibe arquivos Markdown (README, EMENTA, GEMINI) dentro do editor.
extends MarginContainer

@onready var content_label: RichTextLabel = $VBoxContainer/HSplitContainer/ScrollContainer/ContentLabel
@onready var file_list: ItemList = $VBoxContainer/HSplitContainer/FileList

const DOCS = {
	"README.md": "res://README.md",
	"EMENTA.md": "res://EMENTA.md",
	"GEMINI.md": "res://GEMINI.md"
}

func _ready() -> void:
	_setup_file_list()
	# Load README by default if available
	if DOCS.has("README.md"):
		_load_doc(DOCS["README.md"])

func _setup_file_list() -> void:
	if not file_list:
		return
		
	file_list.clear()
	for doc_name in DOCS:
		file_list.add_item(doc_name)
	
	if not file_list.item_selected.is_connected(_on_file_selected):
		file_list.item_selected.connect(_on_file_selected)

func _on_file_selected(index: int) -> void:
	var key = file_list.get_item_text(index)
	var path = DOCS.get(key)
	if path:
		_load_doc(path)

func _load_doc(path: String) -> void:
	if not FileAccess.file_exists(path):
		content_label.text = "[color=red]Arquivo não encontrado: " + path + "[/color]"
		return
		
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		# Basic markdown cleanup/support if needed, but RichTextLabel does OK with basic text.
		# Ideally we would parse MD to BBCode, but raw text is a good start.
		content_label.text = text
	else:
		content_label.text = "[color=red]Erro ao ler arquivo: " + path + "[/color]"
