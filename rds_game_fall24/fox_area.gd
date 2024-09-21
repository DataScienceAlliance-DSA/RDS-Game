extends Area2D

var interactor

@onready var dialogue_ui: MarginContainer = UI.get_node("Dialogue")

func _ready():
	self.set_process(false)

## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # enable area interaction screen
	
	dialogue_ui.visible = true
	dialogue_ui.open_dialogue("Fox")

## PROCESS runs after interaction starts. player can disable interaction while this is running
func _process(_delta):
	if Input.is_action_just_pressed("interaction"):
		interactor.enable_process() # activate player
		self.set_process(false)		# disable area interaction screen
		dialogue_ui.visible = false
