extends Area2D

var interactor

@onready var dialogue_ui: MarginContainer = UI.get_node("Dialogue")
@onready var interactions = 0

func _ready():
	self.set_process(false)

## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # reason why its here... we don't know - deeg
	
	#logic
	
	interactions = interactions + 1	# increment interactions made with this area
	match interactions:
		1:
			dialogue_ui.open_dialogue("res://Scripts/Dialogues/Cauldron/FoxIntro.json", self)
		_:
			dialogue_ui.open_dialogue("res://Scripts/Dialogues/Cauldron/FoxBlurb.json", self)

func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(false)
