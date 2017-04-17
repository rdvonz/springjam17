extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var anim
var character
var is_stopped
var diag_box

func _ready():
	get_node("Area2D").connect("body_enter", self, "stop_character")
	get_node("Area2D").connect("body_exit", self, "start_character")
	diag_box = get_node("dialog_box")
	anim = get_node("AnimationPlayer")
	character = get_node("sprite")
	set_process(true)
	set_process_input(true)
	
func stop_character(body):
	if not body.is_chatting():
		body.set_chatting_with(get_index())
		print("stop")
		anim.stop()
		get_node("talk").show()
		is_stopped = true
	
	#get_node("dialog_box").show()
	
	
func start_character(body):
	body.stop_chatting()
	print("start")
	anim.play("walk")
	is_stopped = false
	get_node("talk").hide()
	get_node("dialog_box").hide()

func _input(event):
	if(event.is_action_pressed("INPUT_INTERACT")):
		diag_box.show()
		diag_box.get_node("diag_text/Label").next_dialog()
		if is_stopped:
			get_node("dialog_box").show()
			get_node("talk").hide()

func _process(delta):
	if not is_stopped:
		set_pos(Vector2(get_pos().x - delta*100, get_pos().y))