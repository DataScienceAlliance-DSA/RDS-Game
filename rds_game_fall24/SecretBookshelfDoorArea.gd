extends Area2D

var interactor
@onready var interact_count = 0

@onready var monologue = UI.get_node("Monologue") # reference to monologue script

func open_bookshelf():
	self.get_node("../OpenDoor").visible = true
	self.get_node("../DoorShadow").visible = true
	self.get_node("../OriginalBound").disabled = true

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
			self.get_node("../OpenDoor").visible = true
			self.get_node("../DoorShadow").visible = true
			self.get_node("../OriginalBound").disabled = true
			monologue.open_3choice_dialogue("res://Scripts/Monologues/Intro/BookshelfAmbient.json", null)
			await monologue.closed_signal
			
			# fades back
			UI.fade(false)
			await UI.ui_change_complete
		_:
			pass
	
	interactor.resume()
