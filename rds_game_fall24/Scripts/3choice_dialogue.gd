extends MarginContainer

var dialogue_dict = {}		# current dialogue dictionary
var current_dialogue_id		# current dialogue id
var choosing				# boolean, true if player is selecting a choice

var interacted_area

# properties for player character's dialogue box
@onready var choice1_box = (get_node("ChoiceContainer/HBoxContainer/MarginContainer/ChoiceBounds1/ScaleControl/ChoiceTexture1") as TextureRect)
@onready var choice1_text = (get_node("ChoiceContainer/HBoxContainer/MarginContainer/ChoiceBounds1/ScaleControl/ChoiceTexture1/MonologueText") as RichTextLabel)
@onready var choice1_scale = (get_node("ChoiceContainer/HBoxContainer/MarginContainer/ChoiceBounds1/ScaleControl") as Control)

@onready var choice2_box = (get_node("ChoiceContainer/HBoxContainer/MarginContainer2/ChoiceBounds2/ScaleControl/ChoiceTexture2") as TextureRect)
@onready var choice2_text = (get_node("ChoiceContainer/HBoxContainer/MarginContainer2/ChoiceBounds2/ScaleControl/ChoiceTexture2/MonologueText") as RichTextLabel)
@onready var choice2_scale = (get_node("ChoiceContainer/HBoxContainer/MarginContainer2/ChoiceBounds2/ScaleControl") as Control)

@onready var choice3_box = (get_node("ChoiceContainer/HBoxContainer/MarginContainer3/ChoiceBounds3/ScaleControl/ChoiceTexture3") as TextureRect)
@onready var choice3_text = (get_node("ChoiceContainer/HBoxContainer/MarginContainer3/ChoiceBounds3/ScaleControl/ChoiceTexture3/MonologueText") as RichTextLabel)
@onready var choice3_scale = (get_node("ChoiceContainer/HBoxContainer/MarginContainer3/ChoiceBounds3/ScaleControl") as Control)

# booleans, if given choice is currently hovered by mouse
var choice1_hovered
var choice2_hovered
var choice3_hovered

# strings, next id for each choice
var choice1_next
var choice2_next
var choice3_next
var potential_next_choice	# currently hovered choice

# properties for opposing character's dialogue box
@onready var response_scale = (get_node("TextContainer/PositionControl/ScaleControl") as Control)
@onready var response_avatar = (get_node("TextContainer/PositionControl/ScaleControl/IconCenter/Avatar") as TextureRect)
@onready var response_name = (get_node("TextContainer/PositionControl/ScaleControl/Namecont/DialogueText") as RichTextLabel)
@onready var response_text = (get_node("TextContainer/PositionControl/ScaleControl/Textcont/DialogueText") as RichTextLabel)

func _ready():
	self.set_process(false)

func open_3choice_dialogue(json_path, area):
	# after disabling player & enabling interactable, enable dialogue
	self.visible = true
	self.set_process(true)
	
	# save interactable area for when closing dialogue
	interacted_area = area
	
	# parse dialogue and process first line
	dialogue_dict = parse_dialogue(json_path)
	current_dialogue_id = "root"
	process_next_text()
	self.position.y = 300

func _process(_delta):
	# move dialogue boxes into position post-open_dialogue
	self.position = self.position.lerp(Vector2(0, 0), _delta * 10)
	choice1_box.position = 	choice1_box.position.lerp(Vector2(0, 0), _delta * 10)
	choice2_box.position = 	choice1_box.position.lerp(Vector2(0, 0), _delta * 10)
	choice3_box.position = 	choice1_box.position.lerp(Vector2(0, 0), _delta * 10)
	
	# check for and process dialogue if next button (E) is pressed
	if (Input.is_action_just_pressed("interaction") and !choosing):
		process_next_text()
	elif (choosing) and (Input.is_action_just_pressed("left_click")) and (potential_next_choice != ""):
		current_dialogue_id = potential_next_choice
		process_next_text()

func parse_dialogue(json_path):
	# .json parseing magic a la GDscript manual
	if FileAccess.file_exists(json_path):
		var data_file = FileAccess.open(json_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		
		if parsed_result is Dictionary:
			return parsed_result
		else:
			print("Error reading JSON file. Must result in a dictionary.")

func process_next_text():	
	# get/set current dialogue_id from dictionary
	if choosing:
		choosing = false
	else:
		current_dialogue_id = dialogue_dict[current_dialogue_id]["next"]
	
	if current_dialogue_id == "end":	# "next": "end" is end-dialogue keyword in json
		close_3choice_dialogue()
	else:
		# get/set character name and text accordingly from dictionary
		var character_name = dialogue_dict[current_dialogue_id]["name"]
		var character_text = dialogue_dict[current_dialogue_id]["text"]["en"]
		
		response_avatar.texture = load("res://assets/ui_assets/portraits/"+character_name+".PNG")
		response_name.text = "[left][color=white][b]"+character_name+"[/b]"
		response_text.text = "[left][color=white]"+character_text
		
		if (dialogue_dict[current_dialogue_id].has("choices")):
			choosing = true
			
			choice1_text.text = "[center][color=black][b]" + dialogue_dict[current_dialogue_id]["choices"][0]["text"]["en"]
			choice2_text.text = "[center][color=black][b]" + dialogue_dict[current_dialogue_id]["choices"][1]["text"]["en"]
			choice3_text.text = "[center][color=black][b]" + dialogue_dict[current_dialogue_id]["choices"][2]["text"]["en"]
			
			choice1_next = dialogue_dict[current_dialogue_id]["choices"][0]["next"]
			choice2_next = dialogue_dict[current_dialogue_id]["choices"][1]["next"]
			choice3_next = dialogue_dict[current_dialogue_id]["choices"][2]["next"]
			
			choice1_box.position = Vector2(0, 550)
			choice2_box.position = Vector2(0, 550)
			choice3_box.position = Vector2(0, 550)
			
			choice1_box.visible = true
			choice2_box.visible = true
			choice3_box.visible = true
		else:
			choice1_box.visible = false
			choice2_box.visible = false
			choice3_box.visible = false

func close_3choice_dialogue():
	# disable dialogue & interactable, enable player
	self.visible = false
	self.set_process(false)
	interacted_area.end_interaction()

func _on_choice_bounds_3_mouse_entered():
	choice3_hovered = true
	choice3_scale.scale = Vector2(0.9, 0.9)
	potential_next_choice = choice3_next

func _on_choice_bounds_3_mouse_exited():
	choice3_hovered = false
	choice3_scale.scale = Vector2(1, 1)
	potential_next_choice = ""

func _on_choice_bounds_2_mouse_entered():
	choice2_hovered = true
	choice2_scale.scale = Vector2(0.9, 0.9)
	potential_next_choice = choice2_next

func _on_choice_bounds_2_mouse_exited():
	choice2_hovered = false
	choice2_scale.scale = Vector2(1, 1)
	potential_next_choice = ""

func _on_choice_bounds_1_mouse_entered():
	choice1_hovered = true
	choice1_scale.scale = Vector2(0.9, 0.9)
	potential_next_choice = choice1_next

func _on_choice_bounds_1_mouse_exited():
	choice1_hovered = false
	choice1_scale.scale = Vector2(1, 1)
	potential_next_choice = ""
