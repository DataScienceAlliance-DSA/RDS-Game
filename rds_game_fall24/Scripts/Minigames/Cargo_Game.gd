extends Control

@onready var grid = $MarginContainer/HBoxContainer/PanelContainer2/GridContainer.get_children()
var line_set

var shape_textures

var active_wire
var hovered_cell

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
	
	for cell in grid:
		cell.mouse_entered.connect(func(): hovered_cell = cell)
		cell.mouse_exited.connect(func(): if hovered_cell == cell: hovered_cell = null)

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

func check_game():
	pass

func _process(_delta):
	if (hovered_cell): print(hovered_cell.name)
	else: print("")
	
	if !line_set:
		var pointA = grid[30]
		var pointB = grid[35]
		
		var line = Line2D.new()
		print(pointA.global_position)
		line.add_point(pointA.global_position + pointA.size / 2.)
		line.add_point(pointB.global_position + pointB.size / 2.)
		line.z_index = 1
		self.add_child(line)
		print(grid.size())
		
		line_set = true
