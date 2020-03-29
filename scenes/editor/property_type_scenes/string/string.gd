extends Control

export var button : NodePath

onready var button_node : LineEdit = get_node(button)

var value = true

func _ready():
	button_node.connect("pressed", self, "update_value")

func set_value(value: bool):
	value = value

func get_value() -> bool:
	return value

func update_value():
	get_node("../").update_value(get_value())
