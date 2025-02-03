extends CanvasLayer

@onready var ui_shapes = {
	0: $HBoxContainer/Circle,
	1: $HBoxContainer/X,
	2: $HBoxContainer/Diamond,
	3: $HBoxContainer/Hexagon,
	4: $HBoxContainer/Square,
	5: $HBoxContainer/Triangle
}

@onready var timer = $Timer
@onready var timer_label = $RichTextLabel
@onready var root_scene = get_node("..")
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var villagers : Array[SickVillager] = [] # array of all on-screen villagers
@onready var max_villagers : int = 10 # total # of villagers that can be on screen at a time
@onready var villager_scene = load("res://Scene Folder/Character Scenes/sick_villager.tscn")

var game_running : bool # runs npc generation in process if true

# Store collected shapes in a set to track which shapes have been collected
var collected_shapes = []

func _ready():
	var camera = player.get_node("Camera2D")
	camera.limit_left = 192.
	camera.limit_right = 1920.
	camera.limit_top = 192.
	camera.limit_bottom = 1152.
	
	UI.start_scene_change(false, false, "")
	game_running = true

func _process(delta):
	# Get the remaining time
	var time_left = timer.time_left
	
	#Calculate minutes and seconds
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	
	#Format the time as MM:SS
	var time_text = "%02d:%02d" % [minutes, seconds]

	#Update the RichText Label
	timer_label.text = time_text
	
	for villager in villagers:
		if villager.villager_complete:
			villagers.erase(villager)
			villager.queue_free()
	
	if (!game_running): return
	if (collected_shapes.size() == 6): 
		game_running = false
		UI.get_node("Monologue").open_3choice_dialogue("res://Scripts/Monologues/Fairness/FairnessSegue.json", null)
		await UI.get_node("Monologue").closed_signal
		UI.start_scene_change(true, true, "res://Scene Folder/Minigames/Mixing_Game/GameManager/Mixing_Game.tscn")
	
	# BEGINS GAME: SPAWNING SICK VILLAGERS
	while (villagers.size() != max_villagers):
		var new_villager = villager_scene.instantiate()
		root_scene.add_child(new_villager)
		villagers.append(new_villager)

# Function to light up the shape in the UI
func light_up_shape(index: int):
	#print("light up is being called with index", index)
	if ui_shapes.has(index) and not collected_shapes.has(index):
		ui_shapes[index].visible = true
		collected_shapes.append(index)
		
	else:
		print("Error: Invalid index ", index)

# Function to check if a shape has been collected
func is_shape_collected(index: int) -> bool:
	return index in collected_shapes

func _on_timer_timeout():
	game_running = false
	end_game()
	
func end_game():
	print("Game Over")
