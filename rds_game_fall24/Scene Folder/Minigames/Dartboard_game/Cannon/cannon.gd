extends AnimatableBody2D

# Dart Angel
var dart_angle = 350
# Dart Speed
var dart_speed = 8
# Dart Gravity
var dart_gravity = 5

# Delay
var dart_delay = 0.5 # seconds
var waited = 0

# Shooting as false by default
var shooting = false

# Dart Scene
var dart_scene = preload("res://Scene Folder/Minigames/Dartboard_game/Dart/Dart.tscn")
# Dart Spawn
@onready var dart_spawn = $dart_spawn

# Directional Force for the dart, changes with speed and angle
var directional_force = Vector2()


# ensure the dart angle within a range
func set_dart_angle(value):
	dart_angle = clamp(value, 0, 359)
	
	
#
func update_directional_force():
	directional_force = Vector2(
		cos(dart_angle * (PI/180)), 
		sin(dart_angle * (PI/180)) * dart_speed
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
	if(shooting && waited > dart_delay):
		fire_once()
		waited = 0
	elif(waited <= dart_delay):
		waited += delta
		
		
func fire_once():
	shoot()
	shooting = false


# A function that allows the cannon to shoot bullet
func shoot():
	var dart = dart_scene.instantiate()
	dart.global_position = (dart_spawn.global_position)
	dart.shoot(directional_force, dart_gravity)
	get_parent().add_child(dart)
	
