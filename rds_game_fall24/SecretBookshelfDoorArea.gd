extends Area2D

var interactor
@onready var interact_count = 0

# Called when the player interacts with the secret bookshelf (bottom sprite)
func interact(character):
	print("Interacted with the cauldron")
	
	interactor = character
	interact_count = interact_count + 1
	
	interactor.pause()
	
	match(interact_count):
		1:
			UI.fade(true)
			await UI.ui_change_complete
			UI.fade(false)
			await UI.ui_change_complete
			print("YAEY")
		_:
			pass
	
	interactor.resume()
