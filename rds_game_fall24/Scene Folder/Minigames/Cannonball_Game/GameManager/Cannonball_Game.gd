extends Node2D

var current_bag: Node = null
var current_bag_index = 0  # Start with bag 6 (index 0 in the array)

# Declare an array to store your bag scenes
var bag_scenes = [
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag6.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag5.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag4.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag3.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag2.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag1.tscn")
]

# Velocity settings for bags 4, 3, and 2
# Range of movement for bags 4, 3, and 2 (x min/max values)
var velocities = [Vector2.ZERO, Vector2.ZERO, Vector2(100, 0), Vector2(120, 0), Vector2(150, 0), Vector2.ZERO]
var movement_limits = [Vector2.ZERO, Vector2.ZERO, Vector2(408, 594), Vector2(782, 1100), Vector2(794, 1369), Vector2.ZERO]


# Array of positions corresponding to each bag
var bag_positions = [
	Vector2(367, 629),  # Position for Bag 6
	Vector2(1219, 629),  # Position for Bag 5
	Vector2(408, 372),  # Position for Bag 4
	Vector2(949, 204),  # Position for Bag 3
	Vector2(1083, 526),  # Position for Bag 2
	Vector2(681, 373)   # Position for Bag 1
]

var current_velocity: Vector2 = Vector2.ZERO  # Current velocity of the bag
var moving_left: bool = true  # Direction flag

# References to the platforms and their collision shapes
var platform_1
var platform_1_collision
var platform_2
var platform_2_collision
var platform_3
var platform_3_collision

func _ready():
	UI.start_scene_change(false, false)
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
	if current_bag and current_velocity != Vector2.ZERO:
		# Handle side-to-side movement with smooth slow down
		var pos = current_bag.position
		print(pos)
		if moving_left:
			current_velocity.x = lerp(current_velocity.x, -velocities[current_bag_index].x, 0.05)  # Slow down left
		else:
			current_velocity.x = lerp(current_velocity.x, velocities[current_bag_index].x, 0.05)  # Slow down right

		pos += current_velocity * delta

		# Check movement limits
		var limits = movement_limits[current_bag_index]
		print(current_bag_index)
		if pos.x <= limits.x:  # Reached the left limit
			pos.x = limits.x
			moving_left = false
		elif pos.x >= limits.y:  # Reached the right limit
			pos.x = limits.y
			moving_left = true

		current_bag.position = pos

func load_new_bag():
	# Use call_deferred to ensure the state changes happen after the physics engine processes
	call_deferred("_load_new_bag")
	
func _load_new_bag():
	# If there is an existing bag, remove it
	if current_bag != null:
		current_bag.queue_free()
	
	# Load the current bag based on the current index
	current_bag = bag_scenes[current_bag_index].instantiate()
	
	# Set the new bag's position
	current_bag.position = bag_positions[current_bag_index]
	add_child(current_bag)

	# Set the velocity for side-to-side movement (for bags 4, 3, 2)
	current_velocity = velocities[current_bag_index]

	# Debugging: Print the velocity assigned
	print("Assigned Velocity: ", current_velocity)

	# Connect the bag's custom signal to detect the orb hit
	current_bag.bag_triggered.connect(_on_bag_triggered)

	# Show platforms if we're on Bag 4 (index 2), and keep them visible until Bag 2 (index 4)
	if current_bag_index <= 4 and current_bag_index >= 2:  # Between Bag 4 and Bag 2
		show_platforms()
	else:
		hide_platforms()

	# Update the index for the next bag, decreasing by 1 each time
	current_bag_index += 1

	# If we've reached the last bag, loop back to the first bag
	if current_bag_index >= bag_scenes.size():
		current_bag_index = 0  # Loop back to the first bag

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
	load_new_bag()  # Load the next bag in sequence when the signal is received
	print("loaded new bag")
