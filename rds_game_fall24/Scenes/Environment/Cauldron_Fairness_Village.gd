extends StaticBody2D

@onready var interaction_area : Area2D = get_node("Area2D") # References Area2D node within the sick villager scene
@onready var monologue_ui: MarginContainer = UI.get_node("Monologue") # Currently used to test interaction confirmation

# Interaction Signal
signal interacted_with(character)

# Interaction tracking variables
var interactor = null
var interactions = 0

func _ready():
	# Debugging for when something enters the area
	interaction_area.area_entered.connect(_on_area_entered)

func _on_area_entered(area):
	if area.get_parent() == get_tree().get_root():
		interact(area)
	print("Player entered interaction area!")
	
## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # enable area interaction screen
	print("Successful Interaction")

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
