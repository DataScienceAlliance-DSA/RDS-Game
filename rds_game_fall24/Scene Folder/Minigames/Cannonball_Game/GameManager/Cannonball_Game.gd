extends Node2D

var current_bag: Node = null
# Declare an array to store your bag scenes
var bag_scenes = [
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag6.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag5.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag4.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag3.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag2.tscn"),
	preload("res://Scene Folder/Minigames/Cannonball_Game/Bag/Bag1.tscn")
	# Add more bags as needed
]

# Array of positions corresponding to each bag
var bag_positions = [
	Vector2(258, 646),  # Position for Bag 6
	Vector2(258, 596),  # Position for Bag 5
	Vector2(258, 546),  # Position for Bag 4
	Vector2(258, 496),  # Position for Bag 3
	Vector2(258, 446),  # Position for Bag 2
	Vector2(258, 396)   # Position for Bag 1
]

var current_bag_index = 0  # Start with bag 6 (index 0 in the array)

func _ready():
	load_new_bag()  # Initially load a bag when the scene starts

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
	
	# Connect the bag's custom signal to detect the orb hit
	current_bag.bag_triggered.connect(_on_bag_triggered)

	# Update the index for the next bag, decreasing by 1 each time
	current_bag_index += 1

	# If we've reached the last bag, loop back to the first bag
	if current_bag_index >= bag_scenes.size():
		current_bag_index = 0  # Loop back to the first bag

# Function triggered when the bag's custom signal is emitted
func _on_bag_triggered():
	load_new_bag()  # Load the next bag in sequence when the signal is received
	print("loaded new bag")
