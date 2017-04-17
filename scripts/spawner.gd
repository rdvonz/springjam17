extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var number_instances = 10
onready var timer = get_node("Timer")
var statuses = []
var delay = 5
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	fetch_more_statuses()
	timer.connect("timeout", self, "spawn_new_tooter")
	timer.set_wait_time(1)
	timer.start()

func fetch_more_statuses():
	statuses = mastolib.get_public_timeline()


func spawn_new_tooter():
	if(statuses.size() == 0):
		fetch_more_statuses()
	
	var pos = Vector2(800, 480)
	var character = preload("res://scenes/charcter.tscn").instance()
	var account_name = statuses.keys()[0]
	var u_statuses = statuses[account_name]
	u_statuses = statuses[statuses.keys()[0]]
	character.init(u_statuses, account_name, pos)
	statuses.erase(account_name)
	character.set_as_toplevel(true)
	add_child(character)
	timer.set_wait_time(rand_range(5, 10))
	timer.start()
	