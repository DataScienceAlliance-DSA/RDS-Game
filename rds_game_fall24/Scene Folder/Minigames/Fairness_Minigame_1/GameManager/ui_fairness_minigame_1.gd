extends CanvasLayer

@onready var ui_shapes = {
	0: $HBoxContainer/Circle,
	1: $HBoxContainer/X,
	2: $HBoxContainer/Diamond,
	3: $HBoxContainer/Hexagon,
	4: $HBoxContainer/Square,
	5: $HBoxContainer/Triangle
}

# Store collected shapes in a set to track which shapes have been collected
var collected_shapes = []

# Function to light up the shape in the UI
func light_up_shape(index: int):
	#print("light up is being called with index", index)
	if ui_shapes.has(index) and not collected_shapes.has(index):
		ui_shapes[index].visible = true
		collected_shapes.append(index)
		
	else:
		print("Error: Invalid index ", index)

# Function to check if a shape has been collected
func is_shape_collected(index: int) -> bool:
	return index in collected_shapes
