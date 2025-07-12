extends Area2D

var interactor
@onready var interactions = 0

## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # enable area interaction screen
	
	interactions = interactions + 1	# increment interactions made with this area
	interactor.set_process(false)
	match interactions:
		1:
			UI.monologue.open_3choice_dialogue("res://Resources/Texts/Monologues/0_Tutorial/TutorialEnv/OrbHypothesis.json", self)
		_:
			UI.monologue.open_3choice_dialogue("res://Resources/Texts/Monologues/0_Tutorial/TutorialEnv/CauldronBlurb.json", self)

func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(true)
