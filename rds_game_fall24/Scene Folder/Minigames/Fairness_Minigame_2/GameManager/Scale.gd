extends CanvasLayer

@export var tilt_angle : float = 25.0  # Maximum tilt angle in degrees
var current_tilt : float = 0.0  # Current tilt angle in degrees
var beam : Sprite2D
var left_pan: Sprite2D
var right_pan: Sprite2D

func _ready():
	beam = $ScaleContainer/Beam  # Adjust the path to your Beam node
	left_pan = beam.get_node("Left_Pan")
	right_pan = beam.get_node("Right_Pan")
	
func _process(delta):
	if Input.is_action_pressed("left"):
		current_tilt = clamp(current_tilt - 1, -tilt_angle, tilt_angle)
	elif Input.is_action_pressed("right"):
		current_tilt = clamp(current_tilt + 1, -tilt_angle, tilt_angle)
		
	else:
		current_tilt = lerp(current_tilt, 0.0, 0.1)

	beam.rotation = deg_to_rad(current_tilt)
