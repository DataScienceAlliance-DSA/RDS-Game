extends Area2D

var interactor

@onready var monologue_ui: MarginContainer = UI.get_node("Monologue")
@onready var interactions = 0

func _ready():
	self.set_process(false)

## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # enable area interaction screen
	
	interactions = interactions + 1	# increment interactions made with this area
	match interactions:
		1:
			monologue_ui.open_monologue("res://Scripts/Monologues/Cauldron/OrbHypothesis.json", self)
		_:
			monologue_ui.open_monologue("res://Scripts/Dialogues/Cauldron/CauldronBlurb.json", self)

func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(false)
