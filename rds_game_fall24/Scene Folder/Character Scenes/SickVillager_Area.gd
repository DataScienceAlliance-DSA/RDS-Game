extends Area2D

@onready var shape_sprite : Sprite2D = get_node("../ShapeSprite")
var interactor = null
var shape_index

# Called when the player interacts with the sick villager
func interact(character):
	print("Interacted with Sick Villager!")
	interactor = character
	if shape_sprite.texture != null:
		print("This is the villager shape index", shape_index)
		var character_sprite = character.get_node("ShapeSprite")
		character_sprite.texture = shape_sprite.texture  # Transfer shape to character
		character.shape_index = shape_index
		print("This is the character shape index", character.shape_index)
		shape_sprite.texture = null  # Remove shape from villager
		end_interaction()
		
func end_interaction():
	# disable interactable, enable player (interactor)
	interactor.enable_process()
	self.set_process(false)
