@tool
## Visualizador de Documentação (Grimório).
##
## Carrega e exibe arquivos Markdown (README, EMENTA, GEMINI) dentro do editor.
extends MarginContainer

@onready var content_label: RichTextLabel = $HSplitContainer/ScrollContainer/MarginContainer/ContentLabel
@onready var file_list: ItemList = $HSplitContainer/FileList

# Map of Display Name -> Resource Path
var _found_docs: Dictionary = {}

func _ready() -> void:
	if content_label:
		content_label.bbcode_enabled = true
		content_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	if file_list:
		file_list.item_selected.connect(_on_file_selected)

	refresh_docs()

func refresh_docs() -> void:
	_found_docs.clear()
	_scan_directory("res://")
	_update_file_list()
	
	# Try to load README by default if present, or the first file found
	if _found_docs.size() > 0:
		if _found_docs.has("README.md"):
			_load_doc(_found_docs["README.md"])
		else:
			_load_doc(_found_docs.values()[0])

func _scan_directory(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				# Recurse. We include 'addons' now as requested, only skipping system folders.
				if file_name != "." and file_name != ".." and file_name != ".godot" and file_name != ".git": 
					_scan_directory(path + "/" + file_name)
			else:
				if file_name.ends_with(".md"):
					# Use filename as key. If duplicate, last one wins (simple approach)
					_found_docs[file_name] = path + "/" + file_name
			file_name = dir.get_next()

func _update_file_list() -> void:
	if not file_list:
		return
		
	file_list.clear()
	var keys = _found_docs.keys()
	keys.sort() # Alphabetical order
	
	for doc_name in keys:
		file_list.add_item(doc_name)


func _on_file_selected(index: int) -> void:
	var key = file_list.get_item_text(index)
	var path = _found_docs.get(key)
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
	
	# 0. First Process Fenced Code Blocks (``` ... ```) before anything else
	# Uses (?s) for DOTALL mode to match across newlines
	regex.compile("(?s)```(?:\\w+)?\\n(.*?)```")
	result = regex.sub(result, "[code]$1[/code]", true)
	
	# 1. Then Process Inline Formatting
	
	# Code Blocks (inline)
	regex.compile("`(.*?)`")
	result = regex.sub(result, "[code]$1[/code]", true)
	
	# Bold
	regex.compile("\\*\\*(.*?)\\*\\*")
	result = regex.sub(result, "[b]$1[/b]", true)
	
	# Italic - Using *text* pattern (single asterisks) since underscores conflict with snake_case
	# Note: This must run AFTER bold processing to avoid conflicts with **bold**
	regex.compile("(?<!\\*)\\*(?!\\*)([^*]+)(?<!\\*)\\*(?!\\*)")
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
