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

enum line_types {TRAIL_LINE, HEAD_LINE, STRETCH_LINE, DOT_LINE}
@onready var finished_line_grad : Gradient = load("res://resources/gradients/finished_cargo_line_gradient.tres")
@onready var started_line_grad : Gradient = load("res://resources/gradients/started_cargo_line_gradient.tres")
@onready var trailing_line_grad : Gradient = load("res://resources/gradients/trailing_cargo_line_gradient.tres")

@onready var trajection_shader = load("res://Scene Folder/Minigames/Cannonball_Game/GameManager/trajection.gdshader")
@onready var trajectory_dot = load("res://assets/Cannon_Game/trajectory dot.png")

func _ready():
	shape_textures = [load("res://assets/Fairness_Village/Shapes/shape_1.png"),
						load("res://assets/Fairness_Village/Shapes/shape_2.png"),
						load("res://assets/Fairness_Village/Shapes/shape_3.png"),
						load("res://assets/Fairness_Village/Shapes/shape_4.png"),
						load("res://assets/Fairness_Village/Shapes/shape_5.png"),
						load("res://assets/Fairness_Village/Shapes/shape_6.png")]
	line_set = false
	
	designate(3,3,1,"shape")
	designate(5,5,1,"shape")
	designate(2,1,5,"shape")
	designate(3,4,5,"shape")
	# designate(4,5,0,"block")
	
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

func check_is_block(cell):
	return "_block" in cell.name

func get_opposing_shape_name(cell):
	var shape_name = cell.name.substr(0,7)
	if cell.name.length() > 7: return shape_name
	else: return str(shape_name) + str(2) 

func check_is_adjacent(cell1, cell2):
	var index1 = grid.find(cell1)
	var index2 = grid.find(cell2)
	
	if grid[index2].name.contains("_block"):
		return false
	
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
	cell.name = str(num) + "_" + type
	if (type == "block"):
		cell.modulate = Color(.25,.25,.25,1.)
	elif (type == "shape"): 
		cell.modulate = Color(1.,1.,1.,1.)
		cell.texture = shape_textures[num-1]
	
	grid_dict[cell] = []
	line_dict[cell] = []

func check_game():
	pass

func _process(_delta):
	# begin connection
	if Input.is_action_just_pressed("left_click"):
		if hovered_cell and "_shape" in hovered_cell.name:
			active_shape = hovered_cell
			
			var opposite_shape
			for item in grid_dict:
				if item.name == get_opposing_shape_name(active_shape): opposite_shape = item
			
			var shape_clears = [active_shape, opposite_shape]
			
			for shape in shape_clears:
				grid_dict[shape] = []
				for line in line_dict[shape]:
					line.queue_free()
				line_dict[shape] = []
			prev_hovered_cell = hovered_cell
			
			var set_line = instantiate_cargo_line(line_types.TRAIL_LINE)
			line_dict[active_shape].append(set_line)
			var indicator_line = instantiate_cargo_line(line_types.STRETCH_LINE)
			line_dict[active_shape].append(indicator_line)
			set_line.z_index = 1
			indicator_line.z_index = 2
			add_child(set_line)
			set_line.add_child(indicator_line)
			
			dragging_line = instantiate_cargo_line(line_types.HEAD_LINE)
			add_child(dragging_line)
			dragging_line.z_index = 1
			dragging_line.add_point(active_shape.global_position + Vector2(64.,64.))
			dragging_line.add_point(get_viewport().get_mouse_position())
			
		else: active_shape = null
	
	# drag connection
	if Input.is_action_pressed("left_click"):
		if !active_shape: return
		if hovered_cell and hovered_cell != prev_hovered_cell:
			if check_is_adjacent(prev_hovered_cell, hovered_cell) and !check_is_blocked(hovered_cell) and !check_is_block(hovered_cell) and (!check_is_shape(hovered_cell) or check_same_shape(hovered_cell,active_shape)):
				grid_dict[active_shape].append(hovered_cell)
				
				if (grid_dict[active_shape].size() == 1): 	
					line_dict[active_shape][0].add_point(prev_hovered_cell.global_position + Vector2(64.,64.))
					line_dict[active_shape][1].add_point(prev_hovered_cell.global_position + Vector2(64.,64.))
				line_dict[active_shape][0].add_point(hovered_cell.global_position + Vector2(64.,64.))
				line_dict[active_shape][1].add_point(hovered_cell.global_position + Vector2(64.,64.))
				
				update_cargo_line_visual(line_dict[active_shape][0], grid_dict[active_shape].size() + 1)
				update_stretch_line_visual(line_dict[active_shape][1], grid_dict[active_shape].size() + 1)
				
				dragging_line.set_point_position(0,hovered_cell.global_position + Vector2(64.,64.))
				dragging_line.set_point_position(1,hovered_cell.global_position)
				
				prev_hovered_cell = hovered_cell
		dragging_line.set_point_position(1,get_viewport().get_mouse_position())
	elif !Input.is_action_just_released("left_click"):
		prev_hovered_cell = hovered_cell
	
	# complete connection
	if Input.is_action_just_released("left_click"):
		if !active_shape: return
		if hovered_cell and "_shape" in hovered_cell.name and prev_hovered_cell == hovered_cell:
			if hovered_cell != active_shape:
				if check_same_shape(hovered_cell, active_shape):
					line_dict[active_shape][0].add_point(prev_hovered_cell.global_position + Vector2(64.,64.))
					finish_cargo_line_visual(line_dict[active_shape][0], grid_dict[active_shape].size() + 1)
					finish_stretch_line_visual(line_dict[active_shape][1], grid_dict[active_shape].size() + 1)
					active_shape = null
					dragging_line.queue_free()
					return
		grid_dict[active_shape] = []
		for line in line_dict[active_shape]:
			line.queue_free()
		line_dict[active_shape] = []
		active_shape = null
		dragging_line.queue_free()

func instantiate_cargo_line(line_type):
	var line = Line2D.new()
	
	line.modulate = Color(1.,.941,.902,1.)
	line.width = 42
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	
	if line_type == line_types.TRAIL_LINE: 
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.gradient = started_line_grad
	elif line_type == line_types.HEAD_LINE: 
		line.end_cap_mode = Line2D.LINE_CAP_NONE
		line.gradient = trailing_line_grad
	elif line_type == line_types.STRETCH_LINE:
		line.width = 30
		line.modulate = Color(1.,1.,1.,1.)
		var sm = ShaderMaterial.new()
		sm.shader = trajection_shader
		sm.set_shader_parameter("scrolling_speed", 0.5)
		line.material = sm
		line.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		line.texture = trajectory_dot
		line.texture_mode = Line2D.LINE_TEXTURE_STRETCH
	
	return line

func update_cargo_line_visual(line, length):
	var grad = line.gradient
	grad.set_offset(1,1./length)

func update_stretch_line_visual(line, length):
	var sm = line.material
	sm.set_shader_parameter("scrolling_speed", 2. / length)

func finish_stretch_line_visual(line, length):
	var sm = line.material
	sm.set_shader_parameter("scrolling_speed", 1.5 / length)
	sm.set_shader_parameter("texture_modulate", Color(.950,.894,.853))
	line.texture_mode = Line2D.LINE_TEXTURE_TILE

func finish_cargo_line_visual(line, length):
	var grad = line.gradient
	grad = finished_line_grad
	grad.set_offset(1,1./length)
	grad.set_offset(2,1-1./length)
	grad.set_color(1,Color(.922,.812,.737))
	grad.set_color(2,Color(.922,.812,.737))
	line.gradient = grad
