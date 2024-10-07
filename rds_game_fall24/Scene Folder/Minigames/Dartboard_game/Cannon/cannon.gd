extends Node2D

# Ball Angle
var ball_angle = 300
# Ball Speed
var ball_speed = 8
# Ball Gravity
var ball_gravity = 5

# Delay
var ball_delay = 0.5 # seconds
var waited = 0

# Shooting as false by default
var shooting = false

# Dart Scene
var ball_scene = preload("res://Scene Folder/Minigames/Dartboard_game/Dart/Cannonball.tscn")
# Dart Spawn
@onready var ball_spawn = $dart_spawn

# Directional Force for the dart, changes with speed and angle
var directional_force = Vector2()


# ensure the dart angle within a range
func set_dart_angle(value):
	ball_angle = clamp(value, 0, 359)
	
	
#
func update_directional_force():
	directional_force = Vector2(
		cos(ball_angle * (PI/180)), 
		sin(ball_angle * (PI/180)) * ball_speed
		)
	


# Called when the node enters the scene tree for the first time.
func _ready(): 
	# update directional force
	update_directional_force()
	
	# enable user input
	set_process_input(true)
	
	# enable processing
	set_process(true)
	
func _input(event):
	# if space bar is pressed
	if(event.is_action_pressed('space')):
		shooting = true
	elif(event.is_action_released('space')):
		shooting = false
		
		
func _process(delta):
	if(shooting && waited > ball_delay):
		fire_once()
		waited = 0
	elif(waited <= ball_delay):
		waited += delta
		
		
func fire_once():
	shoot()
	shooting = false


# A function that allows the cannon to shoot bullet
func shoot():
	var ball = ball_scene.instantiate()
	ball.global_position = (ball_spawn.global_position)
	ball.shoot(directional_force, ball_gravity)
	get_parent().add_child(ball)
	
