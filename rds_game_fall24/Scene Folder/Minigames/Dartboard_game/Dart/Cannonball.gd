extends RigidBody2D

# Gravity
var _gravity = 0

# Movement
var _movement = Vector2()

func shoot(directional_force, gravity):
	_movement = directional_force
	_gravity = gravity

func _fixed_process(delta):
	# simulate gravity
	_movement.y += delta * _gravity
	var collision = move_and_collide(_movement)
	
	_movement = _movement.bounce(collision.normal) * 0.6
