extends Control

signal confirmed

@onready var name_input = $PlayerNamePanel/MarginContainer/VBoxContainer/PlayerName
@onready var confirm_button = $PlayerNamePanel/MarginContainer/VBoxContainer/ConfirmButton

func _process(delta):
	if len(name_input.text) > 12: name_input.text = name_input.text.substr(0,11)

func _on_confirm_button_pressed():
	var name = name_input.text.strip_edges()
	if name != "":
		GlobalPlayerName.global_player_name = name
		visible = false
		emit_signal("confirmed")
		print(GlobalPlayerName.global_player_name)
	else:
		GlobalPlayerName.global_player_name = "Hero"
		visible = false
		emit_signal("confirmed")
		print(GlobalPlayerName.global_player_name)
