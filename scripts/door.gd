extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("Area2D").connect("body_enter", self, "_open_door")
	
func _open_door(body):
	print("open_the_door")