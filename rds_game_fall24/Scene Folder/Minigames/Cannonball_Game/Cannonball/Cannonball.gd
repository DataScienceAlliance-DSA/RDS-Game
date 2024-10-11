extends Area2D

var velocity: Vector2
@onready var rigidbody : RigidBody2D = get_node("..")

func _ready():
	rigidbody.set_linear_velocity(velocity)

func change_trajectory(n, fric, rest):
	var v = rigidbody.linear_velocity
	var perp = (v.dot(n) / n.dot(n)) * n
	var para = v - perp
	rigidbody.linear_velocity = ((fric * para) - (rest * perp))
