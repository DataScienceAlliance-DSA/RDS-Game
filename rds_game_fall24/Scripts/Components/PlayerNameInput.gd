extends Control

signal confirmed

@onready var name_input = $MarginContainer/PlayerNamePanel/MarginContainer/VBoxContainer/PlayerName
@onready var confirm_button = $MarginContainer/PlayerNamePanel/MarginContainer/VBoxContainer/ConfirmButton

func _ready():
	confirm_button.pressed.connect(_on_confirm_button_pressed)

func _on_confirm_button_pressed():
	var name = name_input.text.strip_edges()
	if name != "":
		GlobalPlayerName.global_player_name = name
		visible = false
		emit_signal("confirmed")
		print(GlobalPlayerName.global_player_name)
	else:
		print("Name cannot be empty.")
		
