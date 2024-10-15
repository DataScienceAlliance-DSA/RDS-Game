extends Area2D

var velocity: Vector2
@onready var rigidbody : RigidBody2D = get_node("..")

var prev_y_vel : float
var current_y_vel : float

func _ready():
	self.add_to_group("Cannonball")
	rigidbody.set_linear_velocity(velocity)

func change_trajectory(n, fric, rest):
	var v = rigidbody.get_linear_velocity()
	# var perp = (v.dot(n) / n.dot(n)) * n
	# var para = v - perp
	# rigidbody.linear_velocity = ((fric * para) - (rest * perp))
	v.y = prev_y_vel * -0.5
	rigidbody.set_linear_velocity(v)

func _process(delta):
	current_y_vel = rigidbody.get_linear_velocity().y
	
	if ((prev_y_vel as int) != 0) and ((current_y_vel as int) == 0):
		print("HIT")
	
	prev_y_vel = current_y_vel
