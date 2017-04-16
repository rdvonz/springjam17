extends Control
var text
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var button = get_node("Button")
	button.connect("button_down", self, "on_click")

func on_click():
	var input = get_node("Button/LineEdit")
	text = input.get_text()
