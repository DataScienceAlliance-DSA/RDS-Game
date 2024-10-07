extends Node2D

@onready var power_gauge: TextureProgressBar = $"../PowerGauge/TextureProgressBar"  # Reference to the power gauge
@onready var cannonball_scene: PackedScene = preload("res://Scene Folder/Minigames/Dartboard_game/Dart/Cannonball.tscn")  # Preload the cannonball scene

var cannon_tip_position: Vector2 = Vector2(32, -16)  # Replace with the actual position of the cannon's tip

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cannon shoot"):  # Assuming you have an input action called "shoot"
		shoot_cannon()

func shoot_cannon():
	# Get the current power from the progress bar
	var power = 5 * 10
	#power_gauge.value
	# Instance a new cannonball
	var cannonball = cannonball_scene.instantiate() as RigidBody2D
	
	# Set its starting position at the cannon's tip
	cannonball.position = global_position + cannon_tip_position.rotated(rotation)  # Adjust to the cannon's rotation
	
	# Add the cannonball to the scene
	get_parent().add_child(cannonball)
	
	# Calculate velocity based on the cannon's direction and power
	var direction = Vector2(1, 0).rotated(rotation)  # Direction the cannon is facing
	var cannonball_velocity = direction * power * 10  # Multiply by a factor to adjust speed
	
	# Set the cannonball's velocity
	cannonball.set_linear_velocity(cannonball_velocity)
