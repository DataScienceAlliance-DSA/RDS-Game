extends Node2D

var A: float = 2000.0  # Horizontal size of the figure-eight
var B: float = 1000.0  # Vertical size of the figure-eight
var speed: float = 2.0  # Controls how fast the object moves
var time: float = 0.0  # Time variable for the parametric equation

func _process(delta: float) -> void:
	# Update time
	time += speed * delta
	
	# Calculate the x and y coordinates using the figure-eight parametric equations
	var x = A * sin(time)
	var y = B * sin(time) * cos(time)
	
	# Set the position of the object
	position = Vector2(0, 0) + get_viewport_rect().size / 2  # Center it in the screen
