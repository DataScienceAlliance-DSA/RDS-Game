extends Area2D

var interactor
@onready var interact_count = 0

func open_bookshelf():
	self.get_node("../BookshelfSprite").texture = load("res://Assets/0_Tutorial/Tutorial_VeracityEnv/Intro_Room/NewAssets/NewBookshelves/Secret_bookshelf.PNG")
	self.get_node("../SlidingSprite").visible = true
	self.get_node("../Gradient1").visible = true
	self.get_node("../Gradient2").visible = true
	self.get_node("../FirstCollision").disabled = true
	self.get_node("../SecondCollision").disabled = false
	self.get_node("../SecondCollision2").disabled = false

# Called when the player interacts with the secret bookshelf (bottom sprite)
func interact(character):
	
	interactor = character
	interact_count = interact_count + 1
	
	interactor.pause()
	
	match(interact_count):
		1:
			# scene fades to black
			UI.fade(true)
			await UI.ui_change_complete
			
			# change visual state of bookshelf & open dialogue
			open_bookshelf()
			UI.console.open_console("res://Resources/Texts/Monologues/0_Tutorial/TutorialEnv/BookshelfAmbient.json", null)
			await UI.console.console_complete
			
			# fades back
			UI.fade(false)
			await UI.ui_change_complete
		_:
			pass
	
	interactor.resume()
