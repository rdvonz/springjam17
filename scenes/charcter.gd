extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var anim
var character
var is_stopped
var diag_box
var player_body
var character_set

func init(dialog_text, account_name, pos):
	get_node("dialog_box").init(dialog_text)
	set_global_pos(pos)
	get_node("Panel/Label").set_text(account_name)

func _ready():
	get_node("Area2D").connect("body_enter", self, "stop_character")
	get_node("Area2D").connect("body_exit", self, "start_character")
	diag_box = get_node("dialog_box")
	anim = get_node("AnimationPlayer")
	character = get_node("sprite")
	set_process(true)
	set_process_input(true)
	change_sprites(get_node("sprite"), character_set)

func stop_character(body):
	if body.has_method("is_chatting"):
		if not body.is_chatting():
			body.set_chatting_with(get_index())
			print("stop")
			anim.stop()
			get_node("talk").show()
			is_stopped = true
		
	#get_node("dialog_box").show()
	print("stop")
	anim.stop()
	get_node("talk").show()
	is_stopped = true

func start_character(body):
	if body.has_method("stop_chatting"):
		player_body = body
		body.stop_chatting()
		print("start")
		anim.play("walk")
		is_stopped = false
		get_node("talk").hide()
		get_node("dialog_box").hide()

func _input(event):
	if(event.is_action_pressed("INPUT_INTERACT")):
		if is_stopped:
			get_node("dialog_box").show()
			diag_box.get_node("diag_text/Label").next_dialog()
			get_node("talk").hide()


func change_sprites(node, sprite_name):
	for n in node.get_children():
		if n.get_child_count() >= 0:
			if(n.get_type() == "Sprite"):
				var tex_string = "res://assets/" + sprite_name + "/" + n.get_name() + ".png"
				var tex = load(str(tex_string))
				n.set_texture(tex)
				print(tex_string)
				change_sprites(n, sprite_name)
		else:
			if(n.get_type() == "Sprite"):
				var tex_string = "res://assets/" + sprite_name + "/" + n.get_name() + ".png"
				var tex = load(str(tex_string))
				print(tex_string)
				change_sprites(n, sprite_name)

func _process(delta):

	if not is_stopped:
		set_pos(Vector2(get_pos().x - delta*100, get_pos().y))
		
func _init(char_set):
	self.character_set = char_set
