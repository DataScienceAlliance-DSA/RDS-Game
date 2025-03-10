extends Area2D

var interactor

@onready var interactions = 0

## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	UI.start_scene_change(true, true, "res://Scene Folder/Minigames/Fairness_Minigame_1/GameManager/fairness_minigame_1.tscn")
