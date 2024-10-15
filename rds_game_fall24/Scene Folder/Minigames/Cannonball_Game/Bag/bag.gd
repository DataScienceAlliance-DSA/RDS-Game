extends StaticBody2D

@onready var bag_phases = [
	$bag_6,  # Sprite for phase 6
	$bag_5,  # Sprite for phase 5
	$bag_4,  # Sprite for phase 4
	$bag_3,  # Sprite for phase 3
	$bag_2,  # Sprite for phase 2
	$bag_1   # Sprite for phase 1
]

@onready var goal_areas = [
	$bag_6/goal_6,  # Area2D for phase 6
	$bag_5/goal_5,  # Area2D for phase 5
	$bag_4/goal_4,  # Area2D for phase 4
	$bag_3/goal_3,  # Area2D for phase 3
	$bag_2/goal_2,  # Area2D for phase 2
	$bag_1/goal_1   # Area2D for phase 1
]

var current_phase: int = 0  # Tracks the current phase
var bag_phase_changed: bool = false  # Tracks if a bag phase has changed
var last_spawn_position: Vector2  # Stores the last spawn position
		
# Called when the orb enters the bag
func _on_goal_body_entered(body):
	if body.name == "Cannonball":# Check if the orb is named "Cannonball" and phase hasn't changed
		body.queue_free()  # Remove the orb after it enters
		change_bag_phase()
		bag_phase_changed = true  # Mark that a phase change has occurred
		print("Orb entered:", body.name)

# Function to switch between the bag phases
func change_bag_phase():
	# Hide all phases first
	for sprite in bag_phases:
		sprite.visible = false
	for goal_area in goal_areas:
		goal_area.set_deferred("monitoring", false)  # Disable other Area2Ds

	# Move to the next phase
	current_phase += 1
	if current_phase >= bag_phases.size():
		current_phase = 0  # Loop back to the first phase

	# Show the current phase sprite and enable its Area2D
	bag_phases[current_phase].visible = true
	goal_areas[current_phase].set_deferred("monitoring", true)  # Enable Area2D for the current phase
	
	print("Current Bag Index:", current_phase)

# Resetting the bag_phase_changed flag for new orbs
func _on_new_orb_spawned():
	bag_phase_changed = false
