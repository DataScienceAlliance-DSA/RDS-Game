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
	
	timer.start(5)

var initial_dampening: float = 0.75  # Initial dampening factor
var min_bounce_velocity: float = 20.0  # Minimum 	velocity for both x and y to keep the orb bouncing

func _physics_process(delta: float) -> void:
	# Apply gravity to the y-component
	linear_velocity.y += env_gravity * delta
		
		# Apply the dampening factor to reduce velocity after each bounce
		# bounced_velocity.x *= initial_dampening
		# bounced_velocity.y *= initial_dampening
		
	# Ensure at least one component of the velocity is above the minimum bounce velocity
		#if abs(bounced_velocity.x) < min_bounce_velocity and abs(bounced_velocity.y) < min_bounce_velocity:
		#	bounced_velocity = Vector2.ZERO  # Stop movement if both are too small
		#else:
		#	# If only one is below the minimum, adjust it
		#	if abs(bounced_velocity.x) < min_bounce_velocity:
		#		bounced_velocity.x = sign(bounced_velocity.x) * min_bounce_velocity
		
		#	if abs(bounced_velocity.y) < min_bounce_velocity:
		#		bounced_velocity.y = sign(bounced_velocity.y) * min_bounce_velocity
		
			# Update velocity after bounce
		#	velocity = bounced_velocity
	
	# Move the orb with the updated velocity

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
			queue_free()  # Remove the cannonball after scoring
