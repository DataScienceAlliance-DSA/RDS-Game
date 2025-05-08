extends Sprite2D

var counter_textures = [
	preload("res://Assets/0_Tutorial/TutorialMinigame1/orb_counter/blue_counter.png"),
	preload("res://Assets/0_Tutorial/TutorialMinigame1/orb_counter/green_counter.png"),
	preload("res://Assets/0_Tutorial/TutorialMinigame1/orb_counter/lightblue_counter.png"),
	preload("res://Assets/0_Tutorial/TutorialMinigame1/orb_counter/pink_counter.png"),
	preload("res://Assets/0_Tutorial/TutorialMinigame1/orb_counter/purple_counter.png"),
	preload("res://Assets/0_Tutorial/TutorialMinigame1/orb_counter/yellow_counter.png")
]

var states = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = counter_textures[states]
	var source_node = get_node("../../cannon")
	source_node.update_counter.connect(_on_update_counter)

func _on_update_counter():
	print(states)
	states += 1
	if states != 6:
		texture = counter_textures[states]
