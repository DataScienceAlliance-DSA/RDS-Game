extends Area2D

var velocity: Vector2
@onready var characterbody : CharacterBody2D = get_node("..")
@onready var timer : Timer = get_node("../Timer")
@onready var env_gravity : float = 9.81

var prev_y_vel : float
var prev_x_vel : float
var current_y_vel : float

func _ready():
	self.add_to_group("Cannonball")
	get_node("../../cannon").set_process(false) # disable cannon
	
	timer.start(5)

func _physics_process(delta: float) -> void:
	characterbody.velocity.y += env_gravity * delta  # Apply gravity
	
	var collision = characterbody.move_and_collide(characterbody.velocity * delta)
	if collision:
		# Make the ball bounce off the surface
		characterbody.velocity = characterbody.velocity.bounce(collision.get_normal())
	
	characterbody.move_and_slide()


func change_trajectory(n, fric, rest):
	var v = characterbody.get_linear_velocity()
	# var perp = (v.dot(n) / n.dot(n)) * n
	# var para = v - perp
	# characterbody.linear_velocity = ((fric * para) - (rest * perp))
	v.y = prev_y_vel * -0.5
	v.x = prev_x_vel * 0.5
	characterbody.set_linear_velocity(v)

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
