extends RigidBody2D

@onready var timer : Timer = get_node("Timer")
@onready var env_gravity : float = 981
@onready var ricocheting : bool = true

var prev_y_vel : float
var prev_x_vel : float
var current_y_vel : float

func _ready():
	self.add_to_group("Cannonball")
	get_node("../cannon").set_process(false) # disable cannon
	
	timer.start(3)
	
	if self.physics_material_override:
		self.physics_material_override.friction = 100  # Set the friction to a value higher than 1
	else:
		var material = PhysicsMaterial.new()
		material.friction = 100  # Set your desired friction value
		self.physics_material_override = material

var initial_dampening: float = 0.75  # Initial dampening factor
var min_bounce_velocity: float = 20.0  # Minimum 	velocity for both x and y to keep the orb bouncing

func _process(delta):
	if timer.time_left <= 1.5:
		var sprite = get_node("dart") as CanvasItem
		sprite.modulate.a = fmod((timer.time_left * 10), 2.0)

func _physics_process(delta: float) -> void:
	# Apply gravity to the y-component
	linear_velocity.y += env_gravity * delta

func _on_timer_timeout():
	# cannonball deletes self if failed
	self.queue_free() #delete whole cannonball object
	get_node("../cannon").set_process(true) # re-enable cannon

func get_trajectory_angle():
	pass

# Detect when the cannonball collides with something
func _on_body_entered(body):
	if body.name == "Bag":
		if body.is_in_hit_area(global_position):  # Call a custom function to check hit area
			emit_signal("scored")
			get_node("../cannon").set_process(true) # re-enable cannon
			self.queue_free()  # Remove the cannonball after scoring
