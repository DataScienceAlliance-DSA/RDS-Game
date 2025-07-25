extends Control

var dialogue_dict = {}		# current dialogue dictionary
var current_dialogue_id		# current dialogue id

var interacted_area
signal dialogue_complete()
# current dialogue node's text and name
var card_name
var card_text

var current_dialogue_ended

# properties for player character's dialogue box
@onready var player_color = (get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel/PositionControl") as CanvasItem)
@onready var player_scale = (get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel/PositionControl/ScaleControl") as Control)
@onready var player_avatar = (get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel/PositionControl/ScaleControl/IconCenter/PlayerAvatar") as TextureRect)
@onready var player_name = (get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel/PositionControl/ScaleControl/Namecont/DialogueText") as RichTextLabel)
@onready var player_text = (get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel/PositionControl/ScaleControl/Textcont/DialogueText") as RichTextLabel)
@onready var player_arrow = (get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel/PositionControl/ScaleControl/IconCenter/TextureRect/ArrowContainer") as MarginContainer)

@onready var memory_image = get_node("MarginContainer/VBoxContainer/Panel/Memory")

@onready var grid_container = get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel2/VBoxContainer/Spells/GridContainer")
@onready var buttons : Array[Node] = []

# variables for timing and speed of a line of dialogue moving
var next_char_timer : float	# time passed since last character added to string
@onready var next_char_wait : float = 0.015	# time needed to elapse for next character to be added
var char_index : int		# string character endpoint
var interactable

# UI placement variables
var target_position

func _ready():
	self.set_process(false)
	self.connect("dialogue_complete", get_dialogue_finished)
	
	var spell_container = self.get_node("MarginContainer/VBoxContainer/HBoxContainer/Panel2/VBoxContainer/Spells/GridContainer") as Node
	for spell in spell_container.get_children():
		var button = spell.get_node("TextureRect").get_children()[0]
		buttons.append(button)

func load_image(path):
	if path != "": 
		memory_image.visible = true
		memory_image.texture = load(path)
	else: memory_image.visible = false


func open_dialogue(json_path, area):
	# after disabling player & enabling interactable, enable dialogue
	if !interactable: self.position.y = 300
	
	self.visible = true
	self.set_process(true)
	
	# save interactable area for when closing dialogue
	interacted_area = area
	
	# reset player and opposing character text to "..." before dialogue starts
	player_text.text = "[left][color=black]. . ."
	
	# parse dialogue and process first line
	dialogue_dict = parse_dialogue(json_path)
	current_dialogue_id = "root"
	process_next_text()
	interactable = true
	target_position = Vector2(0, 0)
	
	await get_dialogue_finished()
	return true

func _process(_delta):
	# move dialogue boxes into position post-open_dialogue
	self.position = self.position.lerp(target_position, _delta * 10)
	
	if not interactable: return
	
	var target_text = player_text
	var target_arrow = player_arrow
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
		if (current_dialogue_ended):
			target_arrow.visible = false
		else:
			target_arrow.visible = true
		target_arrow.add_theme_constant_override("margin_bottom", (25 * cos(5 * next_char_timer) + 125) / 2)
		if (Input.is_action_just_pressed("interaction")) and !current_dialogue_ended:
			process_next_text()
	
	if (current_dialogue_ended):
		grid_container.scale = grid_container.scale.lerp(Vector2(1.,1.), _delta * 5.)
		grid_container.modulate = grid_container.modulate.lerp(Color(1.,1.,1.,1.),_delta * 5.)
	else:
		grid_container.scale = grid_container.scale.lerp(Vector2(.9,.9), _delta * 5.)
		grid_container.modulate = grid_container.modulate.lerp(Color(.5,.5,.5,1.),_delta * 5.)
	
	for button in buttons:
		var texture = button.get_parent()
		if button.is_hovered() and current_dialogue_ended:
			print(button.name)
			texture.scale = texture.scale.lerp(Vector2(.275,.275), _delta * 5.)
			texture.z_index = 1
		else:
			texture.scale = texture.scale.lerp(Vector2(.25,.25), _delta * 5.)
			texture.z_index = 0

func parse_dialogue(json_path):
	# .json parseing magic via dictionary
	current_dialogue_ended = false
	
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
	
	if "next" in dialogue_dict[current_dialogue_id]:
		current_dialogue_id = dialogue_dict[current_dialogue_id]["next"]
	else:
		current_dialogue_ended = true
	
	if current_dialogue_id == "end":	# "next": "end" is end-dialogue keyword in json
		current_dialogue_ended = true
	else:
		# get/set character name and text accordingly from dictionary
		card_name = dialogue_dict[current_dialogue_id]["name"]
		card_text = dialogue_dict[current_dialogue_id]["text"]["en"]
		
		next_char_timer = 0.0
		
		player_arrow.visible = false
		
		if (card_name == "Player"): player_name.text = "[color=black][b]"+GlobalPlayerName.global_player_name+"[/b][/color]"
		else: player_name.text = "[color=black][b]"+card_name+"[/b][/color]"
		player_color.modulate.v = 1
		player_avatar.texture = load("res://Assets/UI/portraits/"+card_name+".PNG")
		
		if "next" in dialogue_dict[current_dialogue_id]:
			if dialogue_dict[current_dialogue_id]["next"] == "end":
				current_dialogue_ended = true
		else:
			current_dialogue_ended = true

func close_dialogue():
	# disable dialogue & interactable, enable player
	target_position = Vector2(0, 300)
	interactable = false
	
	if interacted_area:
		interacted_area.end_interaction()
	
	dialogue_complete.emit()

func get_dialogue_finished():
	return true
