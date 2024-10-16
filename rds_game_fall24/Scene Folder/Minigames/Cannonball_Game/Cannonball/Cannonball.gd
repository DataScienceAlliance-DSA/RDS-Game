extends Area2D

var velocity: Vector2
@onready var rigidbody : RigidBody2D = get_node("..")
@onready var timer : Timer = get_node("../Timer")

var prev_y_vel : float
var current_y_vel : float

func _ready():
	self.add_to_group("Cannonball")
	rigidbody.set_linear_velocity(velocity)
	
	timer.start(5)

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
		# print("HIT")
		pass
	
	prev_y_vel = current_y_vel

func _on_timer_timeout():
	# cannonball deletes self if failed
	print(self.get_parent())
	self.get_parent().queue_free() #delete whole cannonball object
