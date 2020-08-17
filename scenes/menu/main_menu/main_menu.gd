extends Screen

onready var button_levels : Button = $CenterContainer/VBoxContainer/ButtonLevels
onready var button_editor : Button = $CenterContainer/VBoxContainer/ButtonEditor
onready var button_options : Button = $CenterContainer/VBoxContainer/ButtonOptions
onready var button_quit : Button = $CenterContainer/VBoxContainer/ButtonQuit

const EDITOR_SCENE : PackedScene = preload("res://scenes/editor/editor.tscn")

func _ready() -> void:
	var _connect = button_levels.connect("pressed", self, "on_button_levels_pressed")
	_connect = button_editor.connect("pressed", self, "on_button_editor_pressed")
	_connect = button_options.connect("pressed", self, "on_button_options_pressed")
	_connect = button_quit.connect("pressed", self, "on_button_quit_pressed")

func on_button_levels_pressed() -> void:
	emit_signal("screen_change", "main_menu_screen", "levels_screen")

func on_button_editor_pressed() -> void:
	SavedLevels.selected_level = -1 # No level selected
	get_node("/root/CurrentLevelData")._ready() # Reset level
	var _change_scene = get_tree().change_scene_to(EDITOR_SCENE)

func on_button_options_pressed() -> void:
	pass

func on_button_quit_pressed() -> void:
	get_tree().quit()

