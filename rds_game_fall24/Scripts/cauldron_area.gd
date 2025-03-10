extends Area2D

var interactor

@onready var monologue_ui: MarginContainer = UI.get_node("Monologue")
@onready var interactions = 0
@onready var animation_player = self.get_node("../AnimationPlayer")
@onready var item_stack = []

func _process(delta):
	for area in get_overlapping_areas():
		if (!item_stack.has(area)):
			item_stack.push_back(area)
	
	enable_animation()

func enable_animation():
	if (!item_stack.is_empty()):
		var item_name = item_stack.pop_back().name
		if (item_name != "PlayerArea"):
			set_animation(item_name)
		else:
			enable_animation()

## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # enable area interaction screen
	
	interactions = interactions + 1	# increment interactions made with this area
	interactor.set_process(false)
	match interactions:
		1:
			monologue_ui.open_3choice_dialogue("res://Scripts/Monologues/Cauldron/OrbHypothesis.json", self)
		_:
			monologue_ui.open_3choice_dialogue("res://Scripts/Monologues/Cauldron/CauldronBlurb.json", self)

func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(true)
	
	if (interactions == 1):
		get_tree().current_scene.scene_state = 1
		
		var scene_data = PackedScene.new()
		scene_data.pack(get_tree().get_current_scene())
		ResourceSaver.save(scene_data, "user://Saves/Cauldron_Room.tscn")
		
		UI.start_scene_change(true, true, "res://Scene Folder/Minigames/Cannonball_Game/GameManager/Cannonball_Game.tscn")

func set_animation(anim_name: String):
	animation_player.current_animation = anim_name
