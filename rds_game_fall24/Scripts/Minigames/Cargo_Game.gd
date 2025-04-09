extends Control

@onready var grid = $MarginContainer/HBoxContainer/PanelContainer2/GridContainer.get_children()
var line_set

var shape_textures

var active_shape # current shape that a wire is being dragged out of
@onready var prev_hovered_cell = null
var hovered_cell

var dragging_line

var grid_dict : Dictionary
var line_dict : Dictionary

func _ready():
	shape_textures = [load("res://assets/Fairness_Village/Shapes/shape_1.png"),
						load("res://assets/Fairness_Village/Shapes/shape_2.png"),
						load("res://assets/Fairness_Village/Shapes/shape_3.png"),
						load("res://assets/Fairness_Village/Shapes/shape_4.png"),
						load("res://assets/Fairness_Village/Shapes/shape_5.png"),
						load("res://assets/Fairness_Village/Shapes/shape_6.png")]
	line_set = false
	
	designate(3,3,1,"_shape")
	designate(5,5,1,"_shape")
	designate(2,1,5,"_shape")
	designate(3,4,5,"_shape")
	
	for cell in grid:
		cell.mouse_entered.connect(func(): hovered_cell = cell)
		cell.mouse_exited.connect(func(): if hovered_cell == cell: hovered_cell = null)

func check_is_blocked(cell):
	for key in grid_dict.keys():
		if cell in grid_dict[key]:
			return true
	return false

func check_same_shape(cell1, cell2):
	return (cell1.name.substr(0,7) == cell2.name.substr(0,7)) and (cell1.name != cell2.name)

func check_is_shape(cell):
	return "_shape" in cell.name

func check_is_adjacent(cell1, cell2):
	var index1 = grid.find(cell1)
	var index2 = grid.find(cell2)
	var x1 = index1 % 6
	var y1 = index1 / 6
	var x2 = index2 % 6
	var y2 = index2 / 6
	
	var dx = abs(x1 - x2)
	var dy = abs(y1 - y2)
	
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)

# DESIGNATIONS:
# 0: blank
# 1-6: respective shape
# TYPES:
# "_wire"
# "_shape"
func designate(i, j, num, type):
	var cell = grid[i+j*6]
	cell.name = str(num) + type
	if (type == "_wire"):
		cell.modulate = Color(1.,1.,1.,0.)
	elif (type == "_shape"): 
		cell.modulate = Color(1.,1.,1.,1.)
		cell.texture = shape_textures[num-1]
	
	grid_dict[cell] = []
	line_dict[cell] = []

func check_game():
	pass

func _process(_delta):
	# Click down
	if Input.is_action_just_pressed("left_click"):
		if hovered_cell and "_shape" in hovered_cell.name:
			active_shape = hovered_cell
			
			grid_dict[active_shape] = []
			for line in line_dict[active_shape]:
				line.queue_free()
			line_dict[active_shape] = []
			prev_hovered_cell = hovered_cell
			
			dragging_line = Line2D.new()
			add_child(dragging_line)
			dragging_line.z_index = 1
			dragging_line.add_point(active_shape.global_position + Vector2(64.,64.))
			dragging_line.add_point(get_viewport().get_mouse_position())
			
		else: active_shape = null
	
	# Click hold
	if Input.is_action_pressed("left_click"):
		if !active_shape: return
		if hovered_cell and hovered_cell != prev_hovered_cell:
			print("GOOP")
			if check_is_adjacent(prev_hovered_cell, hovered_cell) and !check_is_blocked(hovered_cell) and (!check_is_shape(hovered_cell) or check_same_shape(hovered_cell,active_shape)):
				grid_dict[active_shape].append(hovered_cell)
				var set_line = Line2D.new()
				set_line.add_point(prev_hovered_cell.global_position + Vector2(64.,64.))
				set_line.add_point(hovered_cell.global_position + Vector2(64.,64.))
				add_child(set_line)
				set_line.z_index = 1
				line_dict[active_shape].append(set_line)
				dragging_line.set_point_position(0,hovered_cell.global_position + Vector2(64.,64.))
				prev_hovered_cell = hovered_cell
		dragging_line.set_point_position(1,get_viewport().get_mouse_position())
	else:
		prev_hovered_cell = hovered_cell
	
	# Click release
	if Input.is_action_just_released("left_click"):
		if !active_shape: return
		if hovered_cell and "_shape" in hovered_cell.name:
			if hovered_cell != active_shape:
				if check_same_shape(hovered_cell, active_shape):
					print("Wires connected successfully!")
					print(grid_dict)
					active_shape = null
					dragging_line.queue_free()
					return
		grid_dict[active_shape] = []
		for line in line_dict[active_shape]:
			line.queue_free()
		line_dict[active_shape] = []
		active_shape = null
		dragging_line.queue_free()

