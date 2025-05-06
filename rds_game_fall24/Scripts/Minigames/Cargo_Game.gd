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
var complete_dict : Dictionary

enum line_types {TRAIL_LINE, HEAD_LINE, STRETCH_LINE, DOT_LINE}
@onready var finished_line_grad : Gradient = load("res://resources/gradients/finished_cargo_line_gradient.tres")
@onready var started_line_grad : Gradient = load("res://resources/gradients/started_cargo_line_gradient.tres")
@onready var trailing_line_grad : Gradient = load("res://resources/gradients/trailing_cargo_line_gradient.tres")

@onready var trajection_shader = load("res://Scene Folder/Minigames/Cannonball_Game/GameManager/trajection.gdshader")
@onready var trajectory_dot = load("res://assets/Cannon_Game/trajectory dot.png")

## GAME LOGIC
var game_running
@onready var stage = 0
@onready var stage_timer = 0.
@export var timer_start : float
@onready var undesignating_timer = 0.
@onready var game_timer = 0.
# VISUALS
@onready var active_shape_textures = []
@onready var clearing_lines = []
@onready var clearing_shapes = []
signal stage_visuals_cleared # emitted when stage's visuals are cleared to usher in next visuals
@onready var undesignating = false
@onready var timer = $MarginContainer/Panel/Timer

func _ready():
	shape_textures = [load("res://assets/Fairness_Village/Shapes/shape_1.png"),
						load("res://assets/Fairness_Village/Shapes/shape_2.png"),
						load("res://assets/Fairness_Village/Shapes/shape_3.png"),
						load("res://assets/Fairness_Village/Shapes/shape_4.png"),
						load("res://assets/Fairness_Village/Shapes/shape_5.png"),
						load("res://assets/Fairness_Village/Shapes/shape_6.png")]
	line_set = false
	
	for cell in grid:
		cell.mouse_entered.connect(func(): hovered_cell = cell)
		cell.mouse_exited.connect(func(): if hovered_cell == cell: hovered_cell = null)
	
	start_game()

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
	
	grid_dict[cell] = []
	line_dict[cell] = []
	complete_dict[cell] = []
	
	var cell_texture = cell.get_node("TextureRect")
	cell_texture.texture = shape_textures[num-1]
	if cell not in clearing_shapes: cell_texture.scale = Vector2(0.,0.)
	cell_texture.modulate = Color(1.,1.,1.,1.)
	
	active_shape_textures.append(cell_texture)

func undesignate_all():
	for cell in grid:
		cell.name = "Control"
		grid_dict.clear()
		for shape in line_dict.keys():
			for line in line_dict[shape]:
				clearing_lines.append(line)
			clearing_shapes.append(shape)
		line_dict.clear()
		complete_dict.clear()
		
		var cell_texture = cell.get_node("TextureRect")
		# if cell not in clearing_shapes: cell_texture.modulate = Color(0.,0.,0.,0.)
	
	undesignating = true
	undesignating_timer = 0.
	active_shape_textures = []

func start_game():
	game_running = true
	game_timer = timer_start
	next_stage()

func end_game(complete):
	game_running = false
	timer.text = "[center][color=black]0:00"
	
	# clear active drag
	grid_dict[active_shape] = []
	if line_dict and active_shape:
		if line_dict.has(active_shape):
			for line in line_dict[active_shape]:
				line.queue_free()
			line_dict[active_shape] = []
	active_shape = null
	if dragging_line and is_instance_valid(dragging_line):
		dragging_line.queue_free()
	
	if complete:
		print("GAME BEAT")
	else:
		undesignate_all()
		print("GAME FAILED")

func check_game():
	pass

func next_stage():
	stage = stage + 1
	active_shape_textures = []
	
	stage_timer = 0.
	
	match(stage):
		1:
			designate(1,1,0,"shape")
			designate(4,4,0,"shape")
		2:
			undesignate_all()
			await stage_visuals_cleared
			designate(3,3,1,"shape")
			designate(5,5,1,"shape")
			designate(2,1,5,"shape")
			designate(3,4,5,"shape")
		3:
			undesignate_all()
			await stage_visuals_cleared
			designate(5,0,0,"shape")
			designate(4,4,0,"shape")
			designate(3,2,2,"shape")
			designate(1,4,2,"shape")
			designate(1,3,4,"shape")
			designate(3,3,4,"shape")
			designate(5,1,5,"shape")
			designate(4,5,5,"shape")
		4:
			undesignate_all()
			await stage_visuals_cleared
			designate(5,0,2,"shape")
			designate(3,4,2,"shape")
			designate(2,2,3,"shape")
			designate(4,4,3,"shape")
			designate(1,2,4,"shape")
			designate(5,3,4,"shape")
			designate(3,3,0,"shape")
			designate(1,4,0,"shape")
			designate(5,4,1,"shape")
			designate(3,5,1,"shape")
		5:
			undesignate_all()
			await stage_visuals_cleared
			designate(2,0,0,"shape")
			designate(0,2,0,"shape")
			designate(2,1,1,"shape")
			designate(5,3,1,"shape")
			designate(2,2,2,"shape")
			designate(5,2,2,"shape")
			designate(1,4,3,"shape")
			designate(3,3,3,"shape")
			designate(4,1,4,"shape")
			designate(3,4,4,"shape")
		6:
			undesignate_all()
			await stage_visuals_cleared
			designate(0,0,0,"shape")
			designate(5,4,0,"shape")
			designate(1,1,1,"shape")
			designate(0,5,1,"shape")
			designate(1,2,2,"shape")
			designate(3,5,2,"shape")
			designate(2,1,3,"shape")
			designate(2,4,3,"shape")
			designate(3,1,4,"shape")
			designate(5,5,4,"shape")
			designate(4,1,5,"shape")
			designate(4,3,5,"shape")
		7:
			undesignate_all()
			end_game(true)

func _process(_delta):
	if undesignating:
		if undesignating_timer < 1.: 
			var fade_factor = cos((undesignating_timer*PI/2.))
			for line in clearing_lines:
				line.modulate.a = fade_factor
			for shape in clearing_shapes:
				shape.modulate.a = fade_factor
			undesignating_timer = undesignating_timer + _delta
		else: 
			for line in clearing_lines:
				line.queue_free()
			clearing_lines = []
			clearing_shapes = []
			undesignating = false
			stage_visuals_cleared.emit()
	
	if !game_running: return
	
	game_timer = game_timer - _delta
	if game_timer <= 0.: 
		end_game(false)
		return
	
	var min = floor(game_timer / 60.)
	var sec = game_timer - min * 60.
	var between = ":0" if sec < 10. else ":"
	timer.text = "[center][color=black]" + str(min) + between + str(int(sec))
	
	print(timer.text)
	
	# game logic process
	var completion_tally = 0
	for line in complete_dict.keys():
		if (complete_dict[line]): completion_tally = completion_tally + 1
	if (completion_tally == (complete_dict.size() / 2) and stage_timer > 1.5): next_stage()
	
	# game visuals process
	if !undesignating:
		stage_timer = stage_timer + _delta
		for texture in active_shape_textures:
			if stage_timer < 1.: texture.rotation = -PI * cos((stage_timer - 1) * PI) - PI
			if stage_timer < 2.:
				var scale_factor = -sin(PI*stage_timer)/(PI*stage_timer) + 1.
				texture.scale = Vector2(scale_factor,scale_factor)
	
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
				complete_dict[shape] = false
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
					complete_dict[active_shape] = true
					active_shape = null
					if dragging_line and is_instance_valid(dragging_line):
						dragging_line.queue_free()
					return
		grid_dict[active_shape] = []
		for line in line_dict[active_shape]:
			line.queue_free()
		line_dict[active_shape] = []
		active_shape = null
		if dragging_line and is_instance_valid(dragging_line):
			dragging_line.queue_free()

func instantiate_cargo_line(line_type):
	var line = Line2D.new()
	
	line.modulate = Color(1.,.941,.902,1.)
	line.width = 42
	line.joint_mode = Line2D.LINE_JOINT_ROUND
	
	if line_type == line_types.TRAIL_LINE: 
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		line.gradient = started_line_grad
		line.modulate.a = .8
	elif line_type == line_types.HEAD_LINE: 
		line.end_cap_mode = Line2D.LINE_CAP_NONE
		line.gradient = trailing_line_grad
		line.modulate.a = .8
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
	line.modulate.a = .8
