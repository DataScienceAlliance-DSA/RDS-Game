extends Node2D

var A: float = 460  # Horizontal size of the figure-eight
var B: float = 200  # Vertical size of the figure-eight
var speed: float = 1.0  # Controls how fast the object moves
var time: float = 0.0  # Time variable for the parametric equation

# Rotation variables
var max_rotation_degrees: float = 35.0
var rotation_speed: float = 1.0
var rotation_direction: int = 1

# Set origin for movement
var custom_origin: Vector2 = Vector2(683, 384) # Use Marker2D to help determine origin position

# Angle in radians for the figure-eight path (PI / 6 = 30 degrees)
var rotation_angle: float = PI / 12 

func _ready():
	set_process(true)
	
func _process(delta: float) -> void:
	# Update time
	time += speed * delta
	
	# Calculate the x and y coordinates using the figure-eight parametric equations
	var x = A * sin(time)
	var y = B * sin(time) * cos(time)
	
	# Apply rotation to the figure out pathing
	var rotated_x = x * cos(rotation_angle) - y * sin(rotation_angle)
	var rotated_y = x * sin(rotation_angle) + y * cos(rotation_angle)
	
	# Set the position of the object
	position = Vector2(rotated_x, rotated_y) + custom_origin
	
		# Update the rotation
	update_rotation(delta)
	
# Function for bag's rotation
func update_rotation(delta: float) -> void:
	# Adjust rotation based on direction
	rotation_degrees += rotation_direction * rotation_speed * delta * 50 # Multiply by 100 to scale effect
	
	#Check if we've reached max rotation in each direction
	if rotation_degrees >= max_rotation_degrees:
		rotation_degrees = max_rotation_degrees
		rotation_direction = -1
	elif rotation_degrees <= -max_rotation_degrees:
		rotation_degrees = -max_rotation_degrees
		rotation_direction = 1