extends Area2D

var velocity: Vector2
@onready var characterbody : CharacterBody2D = get_node("..")
@onready var timer : Timer = get_node("../Timer")
@onready var env_gravity : float = 981
@onready var ricocheting : bool = true

var prev_y_vel : float
var prev_x_vel : float
var current_y_vel : float

func _ready():
	self.add_to_group("Cannonball")
	get_node("../../cannon").set_process(false) # disable cannon
	
	timer.start(5)

var initial_dampening: float = 0.95  # Initial dampening factor
var bounce_count: int = 0  # Counter to track number of bounces
var dampening_increment: float = 0.05  # The rate at which dampening increases after each bounce
var min_bounce_velocity: float = 5.0  # Minimum velocity for both x and y to keep the orb bouncing
var velocity_threshold: float = 20.0  # Velocity threshold below which no more bouncing occurs

func _physics_process(delta: float) -> void:
	# Apply gravity to the y-component
	characterbody.velocity.y += env_gravity * delta

	# Handle collision
	var collision = characterbody.move_and_collide(characterbody.velocity * delta)

	if collision:
		# Get the normal of the surface
		var normal = collision.get_normal()

		# Reflect velocity off the surface normal
		var bounced_velocity = characterbody.velocity.bounce(normal)

		# Exponentially increase the dampening factor based on the bounce count
		var exponential_dampening = initial_dampening + (bounce_count * dampening_increment)
		
		# Apply the dampening factor to reduce velocity after each bounce
		bounced_velocity.x *= exponential_dampening
		bounced_velocity.y *= exponential_dampening
		
		# Ensure minimum x and y velocities to avoid stopping prematurely
		if abs(bounced_velocity.x) < min_bounce_velocity:
			bounced_velocity.x = sign(bounced_velocity.x) * min_bounce_velocity

		if abs(bounced_velocity.y) < min_bounce_velocity:
			bounced_velocity.y = sign(bounced_velocity.y) * min_bounce_velocity

		# Update velocity after bounce
		characterbody.velocity = bounced_velocity

		# Increment bounce counter after each bounce
		bounce_count += 1

	# Move the orb with the updated velocity
	characterbody.move_and_slide()


func _process(delta):
	prev_y_vel = characterbody.velocity.y
	prev_x_vel = characterbody.velocity.x

func _on_timer_timeout():
	# cannonball deletes self if failed
	print(self.get_parent())
	self.get_parent().queue_free() #delete whole cannonball object
	get_node("../../cannon").set_process(true) # re-enable cannon

func get_trajectory_angle():
	pass
