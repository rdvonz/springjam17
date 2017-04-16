extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var dialogText = []
var curDialog = 0
var state = 0
var tick = 0.0
var text_step = .01
var text_visible = 0
onready var timer = get_node("Text Scroll")

func set_dialog_text(text_array):
	dialogText = text_array

func add_dialog_text(text):
	dialogText.push_back(text)
	if(dialogText.size() == 1):
		set_text(dialogText[curDialog])

func change_state(s):
	state = s
	text_visible = 0

	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	set_process(true)
	timer.start()

func _process(delta):
	set_percent_visible(1 - timer.get_time_left()/timer.get_wait_time())
	
func _input(event):
	if(event.is_action_pressed("INPUT_INTERACT") && timer.get_time_left() == 0):
		set_text(dialogText[curDialog])
		#print("%d: %s" %[curDialog, dialogText[curDialog]])
		curDialog = (1 + curDialog) % dialogText.size()
		timer.start()
		