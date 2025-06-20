extends Node2D

signal stop_moving

var current_bag: Node = null
var current_bag_index = 0  # Start with bag 6 (index 0 in the array)
var bag_poof_animation = preload("res://Scenes/UniversalComponents/bag_poof.tscn")

# Declare an array to store your bag scenes
var bag_scenes = [
	preload("res://Scenes/0_Tutorial/TutorialMinigame1/Bag6.tscn"),
	preload("res://Scenes/0_Tutorial/TutorialMinigame1/Bag5.tscn"),
	preload("res://Scenes/0_Tutorial/TutorialMinigame1/Bag4.tscn"),
	preload("res://Scenes/0_Tutorial/TutorialMinigame1/Bag3.tscn"),
	preload("res://Scenes/0_Tutorial/TutorialMinigame1/Bag2.tscn"),
	preload("res://Scenes/0_Tutorial/TutorialMinigame1/Bag1.tscn")
]

# Velocity settings for bags 4, 3, and 2
# Range of movement for bags 4, 3, and 2 (x min/max values)
var velocities = [Vector2.ZERO, Vector2.ZERO, Vector2(100, 0), Vector2(120, 0), Vector2(150, 0), Vector2.ZERO]
var movement_limits = [Vector2.ZERO, Vector2.ZERO, Vector2(408, 594), Vector2(782, 1100), Vector2(794, 1369), Vector2.ZERO]

# Array of positions corresponding to each bag
var bag_positions = [
	Vector2(367, 684),  # Position for Bag 6
	Vector2(1219, 684),  # Position for Bag 5
	Vector2(408, 372),  # Position for Bag 4
	Vector2(949, 204),  # Position for Bag 3
	Vector2(1083, 526),  # Position for Bag 2
	Vector2(681, 373)   # Position for Bag 1
]

var current_velocity: Vector2 = Vector2.ZERO  # Current velocity of the bag
var moving_left: bool = true  # Direction flag

# Variables for tracking missed attempts
var missed_attempts = 0
var max_attempts = 3 # max allowed attempts

# References to the platforms and their collision shapes
var platform_1
var platform_1_collision
var platform_2
var platform_2_collision
var platform_3
var platform_3_collision

# Referencing cannonball scene
var cannonball_scene = preload("res://Scenes/0_Tutorial/TutorialMinigame1/Cannonball.tscn")
@onready var bag_load_phase : int = 1
@onready var bag_load_timer : float = 0.5

func _ready():
	UI.start_scene_change(false, false, "")
	
	# Get the platform nodes and their collision shapes
	platform_1 = $platform_1
	platform_1_collision = $platform_1/CollisionShape2D
	platform_2 = $platform_2
	platform_2_collision = $platform_2/CollisionShape2D
	platform_3 = $platform_3
	platform_3_collision = $platform_3/CollisionShape2D

	# Set platforms to be hidden and their collisions to be disabled at the start
	platform_1.visible = false
	platform_1_collision.disabled = true
	platform_2.visible = false
	platform_2_collision.disabled = true
	platform_3.visible = false
	platform_3_collision.disabled = true
	
	load_new_bag()

# Update loop for moving the bags side-to-side
func _process(delta):
	self.get_node("PowerGauge/PinkCounter/RichTextLabel").text = "[center][b]" + str(get_node("cannon").bag_attempts)
	
	if (bag_load_phase == 1) and (bag_load_timer < 0.5):
		bag_load_timer += delta
	elif (bag_load_phase == 1):
		load_new_bag()
	
	if current_bag and current_velocity != Vector2.ZERO:
		# Handle side-to-side movement with smooth slow down
		var pos = current_bag.position
		#print(pos)
		if moving_left:
			current_velocity.x = lerp(current_velocity.x, -velocities[current_bag_index].x, 0.05)  # Slow down left
		else:
			current_velocity.x = lerp(current_velocity.x, velocities[current_bag_index].x, 0.05)  # Slow down right

		pos += current_velocity * delta

		# Check movement limits
		var limits = movement_limits[current_bag_index]
		#print(current_bag_index)
		if pos.x <= limits.x:  # Reached the left limit
			pos.x = limits.x
			moving_left = false
		elif pos.x >= limits.y:  # Reached the right limit
			pos.x = limits.y
			moving_left = true
		
		current_bag.position = pos

func load_new_bag():
	# Use call_deferred to ensure the state changes happen after the physics engine processes
	if (bag_load_phase == 0):
		bag_load_timer = 0.0
		bag_load_phase = 1
		current_bag.visible = false
		_play_animation_at_position(current_bag.position, "bagpoof_go")
	else:
		bag_load_phase = 0
		_play_animation_at_position(bag_positions[current_bag_index], "bagpoof_come")

func _load_new_bag():
	# If there is an existing bag, remove it
	if current_bag != null:
		current_bag.queue_free()
	
	# Load the current bag based on the current index
	current_bag = bag_scenes[current_bag_index].instantiate()
	
	# Setting main scene reference in the bag
	current_bag.main_scene = self
	
	# Set the new bag's position
	current_bag.position = bag_positions[current_bag_index]
	add_child(current_bag)
	
	# Set the velocity for side-to-side movement (for bags 4, 3, 2)
	current_velocity = velocities[current_bag_index]
	
	# Debugging: Print the velocity assigned
	# Connect the bag's custom signal to detect the orb hit
	current_bag.bag_triggered.connect(_on_bag_triggered)
	
	# Show platforms if we're on Bag 4 (index 2), and keep them visible until Bag 2 (index 4)
	if current_bag_index <= 4 and current_bag_index >= 2:  # Between Bag 4 and Bag 2
		show_platforms()
	else:
		hide_platforms()

func _play_animation_at_position(position: Vector2, animation_name: String):
	var bag_poof = bag_poof_animation.instantiate()
	bag_poof.position = position
	add_child(bag_poof)
	
	bag_poof.get_node("AnimationPlayer").play(animation_name)  # Replace with your animation name
	if (animation_name == "bagpoof_come"):
		bag_poof.animation_complete.connect(_load_new_bag)

# Function to show platforms and enable their collision shapes
func show_platforms():
	platform_1.visible = true
	platform_1_collision.disabled = false
	platform_2.visible = true
	platform_2_collision.disabled = false
	platform_3.visible = true
	platform_3_collision.disabled = false

# Function to hide platforms and disable their collision shapes
func hide_platforms():
	platform_1.visible = false
	platform_1_collision.disabled = true
	platform_2.visible = false
	platform_2_collision.disabled = true
	platform_3.visible = false
	platform_3_collision.disabled = true
	
# Function triggered when the bag's custom signal is emitted
func _on_bag_triggered():
	# Reset missed attempts in the cannon
	var cannon = $cannon
	if current_bag_index == 5:
		end_game()
		return
	# Update the index for the next bag, decreasing by 1 each time
	current_bag_index += 1
	
	# If we've reached the last bag, loop back to the first bag
	if current_bag_index >= bag_scenes.size():
		current_bag_index = 0  # Loop back to the first bag
	
	load_new_bag()  # Load the next bag in sequence when the signal is received

# Function to stop bag motion and drop an orb into it
func perform_auto_drop():
	UI.get_node("Monologue").open_3choice_dialogue("res://Resources/Texts/Dialogues/0_Tutorial/TutorialMinigame1/UnhappyCannon.json", null)
	await UI.get_node("Monologue").closed_signal
	
	if current_bag_index == 5:  # Assuming index 5 is the final bag
		emit_signal("stop_moving")  # Emit the signal to stop movement for the final bag
	else:
		if current_velocity != Vector2.ZERO:
			current_velocity = Vector2.ZERO  # Stop the bag's motion if it's not the final bag
	
	var cannonball = cannonball_scene.instantiate() as RigidBody2D
	var cannonball_sprite = cannonball.get_node("dart") as Sprite2D;
	cannonball.name = "Cannonball"
	
	# Set its starting position at the cannon's tip
	cannonball.position = current_bag.position + Vector2(0, -100)  # Position orb above the bag
	
	# Add the cannonball to the scene
	add_child(cannonball)
	cannonball_sprite.frame = current_bag_index

func end_game():
	bag_load_phase = 0
	_play_animation_at_position(current_bag.position, "bagpoof_go")
	current_bag.visible = false
	UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/MixingSegue.json", null)
	await UI.get_node("Monologue").closed_signal
	UI.start_scene_change(true, true, "res://Scene Folder/Minigames/Mixing_Game/GameManager/Mixing_Game.tscn")
