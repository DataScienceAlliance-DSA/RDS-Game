extends Area2D

@onready var shape_sprite : Sprite2D = get_node("../ShapeSprite")
var interactor = null

# Called when the player interacts with the sick villager
func interact(character):
	print("Interacted with Sick Villager!")
	interactor = character
	if shape_sprite.texture != null:
		var character_sprite = character.get_node("ShapeSprite")
		character_sprite.texture = shape_sprite.texture  # Transfer shape to character
		shape_sprite.texture = null  # Remove shape from villager
		end_interaction()
		
func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(false)
