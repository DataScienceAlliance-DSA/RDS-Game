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

func enable_animation(item_index):
	match(item_index):
		0:
			set_animation("MagentaOrb")
		1:
			set_animation("PinkOrb")
		2:
			set_animation("TealOrb")
		3:
			set_animation("YellowOrb")
		4:
			set_animation("BlueOrb")
		5:
			set_animation("GreenOrb")
		_:
			set_animation("NonOrb")

## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # enable area interaction screen
	
	interactions = interactions + 1	# increment interactions made with this area
	interactor.set_process(false)
	match interactions:
		1:
			monologue_ui.open_3choice_dialogue("res://Resources/Texts/Monologues/0_Tutorial/TutorialEnv/OrbHypothesis.json", self)
		_:
			monologue_ui.open_3choice_dialogue("res://Resources/Texts/Monologues/0_Tutorial/TutorialEnv/CauldronBlurb.json", self)

func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(true)
	
	if (interactions == 1):
		UI.start_scene_change(true, true, "res://Scenes/0_Tutorial/TutorialMinigame1/Cannonball_Game.tscn")

func set_animation(anim_name: String):
	animation_player.current_animation = anim_name
