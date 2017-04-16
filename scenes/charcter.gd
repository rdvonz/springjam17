extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var anim
var character

func _ready():
	get_node("Area2D").connect("body_enter", self, "stop_character")
	get_node("Area2D").connect("body_exit", self, "start_character")
	anim = get_node("AnimationPlayer")
	character = get_node("sprite")
	set_process(true)
	
func stop_character(body):
	print("stop")
	anim.stop()
	set_process(false)
	
func start_character(body):
	print("start")
	anim.play("walk")
	set_process(true)

func _process(delta):
	set_pos(Vector2(get_pos().x - delta*100, get_pos().y))