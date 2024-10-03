extends RigidBody2D


# Gravity
var _gravity = 0

# Movement
var _movement = Vector2()

func shoot(directional_force, gravity):
	_movement = directional_force
	_gravity = gravity
	_fixed_process(true)

func _fixed_process(delta):
	# simulate gravity
	_movement.y += _gravity
