extends Area2D

@export var pull_speed: float = 200.0
@export var teleport_point: Vector2 = Vector2.ZERO

var is_pulling = false
var target_body = null

func _on_body_entered(body):
	if body.name == "Main Character":
		target_body = body
		is_pulling = true
		if target_body.has_method("set_autonomous"):
			target_body.set_autonomous(false)
			
func _process(delta):
	if is_pulling and target_body:
		var direction = global_position.direction_to(target_body.global_position)
		target_body.global_position -= direction * pull_speed * delta
		
		if global_position.distance_to(target_body.global_position) < 20:
			# Teleport when close enough
			target_body.global_position = teleport_point
			if target_body.has method("set_autonomous"):
				target_body.set_autonomous(true)
			is_pulling = false
			

