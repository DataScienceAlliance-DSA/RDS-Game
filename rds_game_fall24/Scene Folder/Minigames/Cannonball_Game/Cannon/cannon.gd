extends Node2D

@onready var power_gauge: TextureProgressBar = $"../PowerGauge/power_gauge"  # Reference to the power gauge
@onready var cannonball_scene: PackedScene = preload("res://Scene Folder/Minigames/Cannonball_Game/Cannonball/Cannonball.tscn")  # Preload the cannonball scene

@onready var cannon_tip_position: Vector2 = self.get_node("./dart_spawn").position  # Replace with the actual position of the cannon's tip

func _ready() -> void:
	if power_gauge == null:
		print("Power gauge not found!")
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("cannon shoot"):  # Assuming you have an input action called "shoot"
		power_gauge.start_fluctuating()
		
	# Stop fluctuating and shoot the cannon when space bar is released
	if Input.is_action_just_released("cannon shoot"):
		var power = power_gauge.stop_fluctuating() # Get the last value before resetting
		shoot_cannon(power)  #Shoot using the current power
	
	if Input.is_action_pressed("up"):
		var rot = self.get_rotation()
		rot = rot - _delta if rot > -(PI/2) else -(PI/2)
		self.set_rotation(rot)
	if Input.is_action_pressed("down"):
		var rot = self.get_rotation()
		rot = rot + _delta if rot < 0 else 0
		self.set_rotation(rot)
	
	cannon_tip_position = self.get_node("./dart_spawn").position

func shoot_cannon(power: float):
	print("Current Power: ", power)

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
