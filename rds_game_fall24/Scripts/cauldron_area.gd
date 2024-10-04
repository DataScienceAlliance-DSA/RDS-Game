extends Area2D

var interactor

@onready var monologue_ui: MarginContainer = UI.get_node("Monologue")
@onready var interactions = 0
@onready var animation_player = $AnimationPlayer

# Mapping frame names to animation names
var item_animations = {
	"PinkOrb": "PinkOrb",
	"TealOrb": "TealOrb",
	"BlueOrb": "BlueOrb",
	"GreenOrb": "GreenOrb",
	"YellowOrb": "YellowOrb",
	"NonOrb": "NonOrb"
}

func _ready():
	self.set_process(false)

# Triggered when an item enters the cauldron's Area2D
func on_item_entered(item_name: String):
	if item_name in item_animations:
		animation_player.play(item_animations[item_name])

## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # enable area interaction screen
	
	interactions = interactions + 1	# increment interactions made with this area
	match interactions:
		1:
			monologue_ui.open_3choice_dialogue("res://Scripts/Monologues/Cauldron/OrbHypothesis.json", self)
		_:
			monologue_ui.open_3choice_dialogue("res://Scripts/Monologues/Cauldron/CauldronBlurb.json", self)

func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(false)
