extends MarginContainer

@export var tilt_angle : float = 25.0  # Maximum tilt angle in degrees
var current_tilt : float = 0.0  # Current tilt angle in degrees
var beam : Sprite2D
var left_pan: Sprite2D
var left_pan_rotate: Control
var right_pan: Sprite2D
var right_pan_rotate: Control

@onready var left_pan_spots = get_tree().get_nodes_in_group("LeftPan")[0].get_children()
@onready var right_pan_spots = get_tree().get_nodes_in_group("RightPan")[0].get_children()

func _ready():
	beam = $Control/Control/ScaleContainer/Beam  # Adjust the path to your Beam node
	left_pan_rotate = get_node("Control/Control/LeftPanRotate")
	left_pan = get_node("Control/Control/LeftPanRotate/Left_Pan")
	right_pan_rotate = get_node("Control/Control/RightPanRotate")
	right_pan = get_node("Control/Control/RightPanRotate/RightPan")
	# drop_spot_left = get_node("../DropSpotLeft")
	# drop_spot_right = get_node("../DropSpotRight")

func _process(delta):
	# if Input.is_action_pressed("left"):
	# 	current_tilt = clamp(current_tilt - 1, -tilt_angle, tilt_angle)
	# elif Input.is_action_pressed("right"):
	# 	current_tilt = clamp(current_tilt + 1, -tilt_angle, tilt_angle)
	# else:
	# 	current_tilt = lerp(current_tilt, 0.0, 0.1)
	
	var weight_score : float = 0
	
	for spot in left_pan_spots:
		for stuff in spot.get_children():
			if (stuff.get_child_count() != 0):
				weight_score -= stuff.name.to_float()
	
	for spot in right_pan_spots:
		for stuff in spot.get_children():
			if (stuff.get_child_count() != 0):
				weight_score += stuff.name.to_float()
	
	var new_tilt = weight_score / 75. * tilt_angle
	current_tilt = lerpf(current_tilt, new_tilt, delta * 3.)
	
	beam.rotation = deg_to_rad(current_tilt)
	left_pan_rotate.rotation = deg_to_rad(current_tilt)
	right_pan_rotate.rotation = deg_to_rad(current_tilt)
	left_pan.rotation = deg_to_rad(-current_tilt)
	right_pan.rotation = deg_to_rad(-current_tilt)
