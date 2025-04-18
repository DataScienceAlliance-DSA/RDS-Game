extends Node2D

var cm : CutsceneManager

@onready var panel = $InformationPanel

func _ready():
	panel.open_ui()

func _process(delta):
	pass
