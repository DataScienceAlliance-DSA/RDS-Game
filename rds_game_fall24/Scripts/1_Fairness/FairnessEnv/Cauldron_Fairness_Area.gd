extends Area2D
@onready var shape_ui = get_node("../../../UIFairnessMinigame1")
var interactor = null

# Called when the player interacts with the sick villager
func interact(character):
	print("Interacted with the cauldron")

	interactor = character
	
	var shape_index = character.shape_index
	
	if (shape_index == null):
		return
	
	print("Cauldron index number", shape_index)
	shape_ui.light_up_shape(shape_index)
	
	var main_character_shape = interactor.get_node("ShapeSprite")
	main_character_shape.texture = null
	character.shape_index = null

func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(false)
