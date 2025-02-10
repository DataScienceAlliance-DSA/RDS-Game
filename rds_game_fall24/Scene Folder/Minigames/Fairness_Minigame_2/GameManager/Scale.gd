extends MarginContainer

@export var tilt_angle : float = 25.0  # Maximum tilt angle in degrees
var current_tilt : float = 0.0  # Current tilt angle in degrees
var beam : Sprite2D
var left_pan: Sprite2D
var left_pan_rotate: Control
var right_pan: Sprite2D
var right_pan_rotate: Control

func _ready():
	beam = $Control/Control/ScaleContainer/Beam  # Adjust the path to your Beam node
	left_pan_rotate = get_node("Control/Control/LeftPanRotate")
	left_pan = get_node("Control/Control/LeftPanRotate/Left_Pan")
	right_pan_rotate = get_node("Control/Control/RightPanRotate")
	right_pan = get_node("Control/Control/RightPanRotate/RightPan")
	# drop_spot_left = get_node("../DropSpotLeft")
	# drop_spot_right = get_node("../DropSpotRight")

func _process(delta):
	if Input.is_action_pressed("left"):
		current_tilt = clamp(current_tilt - 1, -tilt_angle, tilt_angle)
	elif Input.is_action_pressed("right"):
		current_tilt = clamp(current_tilt + 1, -tilt_angle, tilt_angle)
	else:
		current_tilt = lerp(current_tilt, 0.0, 0.1)
	
	beam.rotation = deg_to_rad(current_tilt)
	left_pan_rotate.rotation = deg_to_rad(current_tilt)
	right_pan_rotate.rotation = deg_to_rad(current_tilt)
	left_pan.rotation = deg_to_rad(-current_tilt)
	right_pan.rotation = deg_to_rad(-current_tilt)
