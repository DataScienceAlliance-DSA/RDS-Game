extends MarginContainer

var dialogue_dict = {}		# current dialogue dictionary
var current_dialogue_id		# current dialogue id

var interacted_area
signal dialogue_complete()
# current dialogue node's text and name
var card_name
var card_text

# properties for player character's dialogue box
@onready var player_color = (get_node("PlayerContainer/PositionControl") as CanvasItem)
@onready var player_scale = (get_node("PlayerContainer/PositionControl/ScaleControl") as Control)
@onready var player_avatar = (get_node("PlayerContainer/PositionControl/ScaleControl/IconCenter/PlayerAvatar") as TextureRect)
@onready var player_name = (get_node("PlayerContainer/PositionControl/ScaleControl/Namecont/DialogueText") as RichTextLabel)
@onready var player_text = (get_node("PlayerContainer/PositionControl/ScaleControl/Textcont/DialogueText") as RichTextLabel)
@onready var player_arrow = (get_node("PlayerContainer/PositionControl/ScaleControl/IconCenter/TextureRect/ArrowContainer") as MarginContainer)

# properties for opposing character's dialogue box
@onready var opposing_color = (get_node("CharacterContainer/PositionControl") as CanvasItem)
@onready var opposing_scale = (get_node("CharacterContainer/PositionControl/ScaleControl") as Control)
@onready var opposing_avatar = (get_node("CharacterContainer/PositionControl/ScaleControl/IconCenter/CharacterAvatar") as TextureRect)
@onready var opposing_name = (get_node("CharacterContainer/PositionControl/ScaleControl/Namecont/DialogueText") as RichTextLabel)
@onready var opposing_text = (get_node("CharacterContainer/PositionControl/ScaleControl/Textcont/DialogueText") as RichTextLabel)
@onready var opposing_arrow = (get_node("CharacterContainer/PositionControl/ScaleControl/IconCenter/TextBanner/ArrowContainer") as MarginContainer)

# variables for timing and speed of a line of dialogue moving
var next_char_timer : float	# time passed since last character added to string
@onready var next_char_wait : float = 0.015	# time needed to elapse for next character to be added
var char_index : int		# string character endpoint
var interactable

# UI placement variables
var target_position

# Setting Global Player Name for Dialogue
@onready var player_name_label = $PlayerContainer/PositionControl/ScaleControl/Namecont/DialogueText

func _ready():
	self.set_process(false)
	self.connect("dialogue_complete", get_dialogue_finished)

func open_dialogue(json_path, area):
	# after disabling player & enabling interactable, enable dialogue
	self.visible = true
	self.set_process(true)
	
	# save interactable area for when closing dialogue
	interacted_area = area
	
	# reset player and opposing character text to "..." before dialogue starts
	player_text.text = "[left][color=black]. . ."
	opposing_text.text = "[right][color=black]. . ."
	
	# parse dialogue and process first line
	dialogue_dict = parse_dialogue(json_path)
	current_dialogue_id = "root"
	process_next_text()
	interactable = true
	self.position.y = 300
	target_position = Vector2(0, 0)
	
	await get_dialogue_finished()
	return true

func _process(_delta):
	# move dialogue boxes into position post-open_dialogue
	self.position = self.position.lerp(target_position, _delta * 10)
	
	if not interactable: return
	
	var target_text = opposing_text if card_name != "Player" else player_text
	var target_arrow = opposing_arrow if card_name != "Player" else player_arrow
	# timer system for dialogue string to write itself on UI
	if (next_char_timer >= next_char_wait) and (char_index <= card_text.length()):
		next_char_timer = 0.0
		target_text.text = "[color=black]"+card_text.substr(0,char_index)+"[/color]"
		char_index = char_index + 1
	else:
		next_char_timer += _delta
	
	# check for and process dialogue if next button (E) is pressed
	if (char_index <= card_text.length()):
		if (Input.is_action_just_pressed("interaction")):
			char_index = card_text.length()
	else:
		target_arrow.visible = true
		target_arrow.add_theme_constant_override("margin_bottom", (25 * cos(5 * next_char_timer) + 125) / 2)
		if (Input.is_action_just_pressed("interaction")):
			process_next_text()

func parse_dialogue(json_path):
	# .json parseing magic via dictionary
	if FileAccess.file_exists(json_path):
		var data_file = FileAccess.open(json_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		
		if parsed_result is Dictionary:
			return parsed_result
		else:
			print("Error reading JSON file. Must result in a dictionary.")

func process_next_text():	
	# get/set current dialogue_id from dictionary
	char_index = 1
	current_dialogue_id = dialogue_dict[current_dialogue_id]["next"]
	
	if current_dialogue_id == "end":	# "next": "end" is end-dialogue keyword in json
		close_dialogue()
	else:
		# get/set character name and text accordingly from dictionary
		card_name = dialogue_dict[current_dialogue_id]["name"]
		card_text = dialogue_dict[current_dialogue_id]["text"]["en"]
		
		next_char_timer = 0.0
		
		player_arrow.visible = false
		opposing_arrow.visible = false
		# if dialogue entry name is not Player, edit right text box of UI
		if (dialogue_dict[current_dialogue_id]["name"] != "Player"):
			opposing_name.text = "[right][color=black][b]"+card_name+"[/b][/color]"
			opposing_scale.scale = Vector2(1.4, 1.4)
			opposing_color.modulate.v = 1
			opposing_avatar.texture = load("res://Assets/UI/portraits/"+card_name+".PNG")
			
			player_scale.scale = Vector2(1.25, 1.25)
			player_color.modulate.v = 0.5
		# else, edit left text box of UI
		else:
			print(card_name)
			if (card_name == "Player"): player_name.text = "[color=black][b]"+GlobalPlayerName.global_player_name+"[/b][/color]"
			else: player_name.text = "[color=black][b]"+card_name+"[/b][/color]"
			player_scale.scale = Vector2(1.4, 1.4)
			player_color.modulate.v = 1
			player_avatar.texture = load("res://Assets/UI/portraits/"+card_name+".PNG")
			
			opposing_scale.scale = Vector2(1.25, 1.25)
			opposing_color.modulate.v = 0.5

func close_dialogue():
	# disable dialogue & interactable, enable player
	target_position = Vector2(0, 300)
	interactable = false
	
	if interacted_area:
		interacted_area.end_interaction()
	
	dialogue_complete.emit()

func get_dialogue_finished():
	return true
