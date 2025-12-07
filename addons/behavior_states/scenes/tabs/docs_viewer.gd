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
	if content_label:
		content_label.bbcode_enabled = true
		
	_setup_file_list()
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
		content_label.text = _parse_markdown(text)
	else:
		content_label.text = "[color=red]Erro ao ler arquivo: " + path + "[/color]"

func _parse_markdown(text: String) -> String:
	var result = text
	var regex = RegEx.new()
	
	# 1. First Process Inline Formatting (Bold, Italic, Code)
	# This prevents regex from matching characters inside generated BBCode tags (like 'font_size')
	
	# Code Blocks (inline)
	regex.compile("`(.*?)`")
	result = regex.sub(result, "[code]$1[/code]", true)
	
	# Bold
	regex.compile("\\*\\*(.*?)\\*\\*")
	result = regex.sub(result, "[b]$1[/b]", true)
	
	# Italic (Warning: Underscores can conflict with snake_case or new tags, so we be careful)
	# We try to match _text_ but not __text__ (bold) which ideally is already handled or separate
	regex.compile("(?<!_)_(?!_)(.+?)(?<!_)_(?!_)")
	result = regex.sub(result, "[i]$1[/i]", true)

	# Links [text](url) -> [url=url]text[/url]
	regex.compile("\\[(.*?)\\]\\((.*?)\\)")
	result = regex.sub(result, "[url=$2]$1[/url]", true)

	# 2. Then Process Block Elements / Headers which generate complex tags
	
	# Blockquotes
	regex.compile("(?m)^> (.*)$")
	result = regex.sub(result, "[color=#888888][i]  $1[/i][/color]", true)
	
	# Headers
	regex.compile("(?m)^# (.*)$")
	result = regex.sub(result, "[font_size=32][b]$1[/b][/font_size]", true)
	
	regex.compile("(?m)^## (.*)$")
	result = regex.sub(result, "[font_size=24][b]$1[/b][/font_size]", true)
	
	regex.compile("(?m)^### (.*)$")
	result = regex.sub(result, "[font_size=20][b]$1[/b][/font_size]", true)

	return result
