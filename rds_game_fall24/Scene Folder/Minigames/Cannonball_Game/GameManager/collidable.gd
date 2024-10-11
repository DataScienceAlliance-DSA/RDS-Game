extends Area2D

@onready var rigidbody : RigidBody2D = get_node("..")
@onready var friction = 0.5
@onready var restitution = 0.5

var cannonball_hit

func _process(delta):
	cannonball_hit = false
	
	var areas = self.get_overlapping_areas()
	var cannonball
	
	for area in areas:
		if (area.name == "Cannonball"):
			cannonball = area
			cannonball_hit = true
	
	if (cannonball_hit):
		var normal = cannonball.get_normal()
		cannonball.change_trajectory(normal, friction, restitution)
