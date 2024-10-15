extends Area2D

@onready var rigidbody : RigidBody2D = get_node("..")
@onready var friction = 0
@onready var restitution = 0

var cannonball_hit

func _on_area_entered(area):
	print("help")
	get_tree().call_group("Cannonball","change_trajectory",Vector2(0,1),friction, restitution)
