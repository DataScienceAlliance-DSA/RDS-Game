extends CharacterBody2D

@export var follow_speed = 150.0
var player_position
var target_position
@onready var player =  get_parent().get_node("Player")

func _physics_process(_delta):
	player_position = player.position
	target_position = (player_position - position).normalized()
	
	var magnitude = 0.0
	
	if position.distance_to(player_position) > 100:
		
		var vel = target_position * follow_speed
		magnitude = vel.length()
	
	#if fox enters player area, stop fox velocity
	var theta = atan2(target_position.y, target_position.x)
	
	theta = fmod(theta, TAU)
	if theta < 0.:
		theta += TAU
	
	print(theta)
	
	if (theta <= PI / 4) and (theta >= 7 * PI / 4):
		velocity = Vector2(1.,0.) * magnitude
	if (theta >= PI / 4) and (theta <= 3 * PI / 4):
		velocity = Vector2(0.,1.) * magnitude
	if (theta >= 3 * PI / 4) and (theta <= 5 * PI / 4):
		velocity = Vector2(-1.,0.) * magnitude
	if (theta >= 5 * PI / 4) and (theta <= 7 * PI / 4):
		velocity = Vector2(0.,-1.) * magnitude
	
	move_and_slide()
