extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var tick = 0
var state
var cursor_flicker = 10
var center = Vector2(0, 0)
var size = Vector2(200, 75)
onready var timer = get_node("diag_text/Text Scroll")

func init(pos, dialog_text_array):
	center = pos
	get_node("diag_text/Label").set_dialog_text(dialog_text_array)
	resize_box()

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = Vector2Array()
	points_arc.push_back(center)
	var colors = ColorArray([color])
	var angle_step = (angle_to-angle_from)/float(nb_points)
	var angle_point 

	for i in range(nb_points+1):
	    angle_point = deg2rad(angle_from + (i*angle_step) + 90)
	    points_arc.push_back(center + Vector2(sin(angle_point), cos(angle_point)) * radius)
	draw_polygon(points_arc, colors)
	
#TODO: Make this, like, more programmatic. Loops can be used here. 
func draw_dialog_box(pos, size, color):
	var bevel_radius = 10
	var w = size[0]
	var h = size[1]
	var x = pos[0]
	var y = pos[1]
	var bevel_size = Vector2(w - 2*bevel_radius, bevel_radius)
	var center_box_size = Vector2(w, h-bevel_radius)
	#Bevel Frame
	draw_rect(Rect2(Vector2(x + bevel_radius, y), bevel_size), color)
	draw_rect(Rect2(Vector2(x + bevel_radius, y + h), bevel_size), color)
	
	#Center Box
	var center = Rect2(Vector2(x, y + bevel_radius), center_box_size)
	draw_rect(center, color)
	
	
	draw_circle_arc(Vector2(center.end[0] - bevel_radius, center.pos[1]), bevel_radius, 0, 90, color)
	draw_circle_arc(Vector2(center.pos[0] + bevel_radius, center.pos[1]), bevel_radius, 90, 180, color)
	draw_circle_arc(Vector2(center.pos[0] + bevel_radius, center.end[1]), bevel_radius, 180, 270, color)
	draw_circle_arc(Vector2(center.end[0] - bevel_radius, center.end[1]), bevel_radius, 270, 360, color)

	var text = get_node("diag_text/Label")
	#text.set_pos(Vector2(x + bevel_radius, y + bevel_radius))
	text.edit_set_rect(Rect2(Vector2(x+bevel_radius, y + bevel_radius), Vector2(w - 2*bevel_radius, h - 2*bevel_radius)))
	text.set_autowrap(true)


func flash_cursor(pos, color):
	draw_rect(Rect2(pos, Vect2(20, 20)), color) 

func resize_box():
	var text = get_node("diag_text/Label")
	var lines = text.get_line_count()
	print(lines)
	var vert_size = max(6*lines, 75)
	size = Vector2(230, vert_size)

func _draw():
	
	var radius = 10
	var angle_from = 0
	var angle_to = 90
	var color = Color(0, 0, 0.0)

	draw_dialog_box(center, size, color)
	
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	
	
func _process():
	pass
	