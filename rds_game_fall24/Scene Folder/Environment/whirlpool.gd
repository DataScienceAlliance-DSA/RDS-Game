extends Area2D

@export var pull_strength := 300.0
@export var pull_radius := 200.0

var affected_bodies := []

func _ready():
	connect("body_entered", self, "_on_body_entered")
	connect("body_exited", self, "_on_body_exited")

func _on_body_entered(body):
	if body.has_method("apply_central_force") or body is CharacterBody2D:
		affected_bodies.append(body)

func _on_body_exited(body):
	affected_bodies.erase(body)

func _physics_process(delta):
	for body in affected_bodies:
		if not is_instance_valid(body):
			continue
		var direction = global_position.direction_to(body.global_position)
		var distance = global_position.distance_to(body.global_position)
		var force = direction * -pull_strength * (1.0 - clamp(distance / pull_radius, 0.0, 1.0))
		
		if body is RigidBody2D:
			body.apply_central_force(force)
		elif body is CharacterBody2D:
			body.velocity += force * delta  # assuming you're manually controlling the velocity
