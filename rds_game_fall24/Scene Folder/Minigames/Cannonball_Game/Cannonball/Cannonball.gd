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

var dampening_factor: float = 0.85
var min_bounce_velocity: float =      0.0  # Minimum velocity below which the ball stops bouncing


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
		
		# Apply the dampening factor to both x and y velocities
		bounced_velocity.x *= dampening_factor
		bounced_velocity.y *= dampening_factor
		
		# Ensure there's a minimum velocity to avoid inconsistencies
		if bounced_velocity.length() < min_bounce_velocity:
			bounced_velocity = Vector2.ZERO  # Stop movement if velocity gets too small
		
		characterbody.velocity = bounced_velocity
	
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
