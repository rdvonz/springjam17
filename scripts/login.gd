extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():

	# Should only be necessary once: 
	mastolib.get_access_token(get_node("Control/Button/LineEdit"), get_node("Control/Button"))
	set_process(true)
	


func _process(delta):
	if mastolib.file_exists("user_access_token"):
		global.goto_scene("res://scenes/main.tscn")
		OS.delay_msec(500)
