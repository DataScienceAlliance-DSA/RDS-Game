extends MarginContainer

var dialogue_dict = {}		# current dialogue dictionary
var current_dialogue_id		# current dialogue id

var interacted_area

signal console_complete

#variables to fix the space bar shwoing the full text ahead of time
var can_advance = false
var skip_requested = false
var finished_line = false

# varaibles for ui dynamic changes
var interactable : bool
@onready var target_position : Vector2 = Vector2(0, 0)
var character_text : String
var italic_character_text : String
# variables for timing and speed of a line of dialogue moving
var next_char_timer : float	# time passed since last character added to string
@onready var next_char_wait : float = 0.025	# time needed to elapse for next character to be added
var char_index : int

@onready var response_text = $TextContainer/Panel/TextCont/RichTextLabel
@onready var response_arrow = $TextContainer/Panel/ArrowCont

# signal: tells non-area caller that the dialogue is closed
signal closed_signal

@onready var text_color = "black"

func _ready():
	self.set_process(false)

func open_console(json_path, area):
	# after disabling player & enabling interactable, enable dialogue
	self.visible = true
	self.set_process(true)
	
	# save interactable area for when closing dialogue
	interacted_area = area
	
	# parse dialogue and process first line
	dialogue_dict = parse_dialogue(json_path)
	current_dialogue_id = "root"
	process_next_text()
	interactable = true
	self.position.y = 300
	target_position = Vector2(0, 0)

func _process(_delta):
	# move dialogue boxes into position post-open_dialogue
	self.position = self.position.lerp(target_position, _delta * 10)
	if not interactable: return
	
	next_char_timer += _delta
	# timer system for dialogue string to write itself on UI
	if char_index <= character_text.length():
		if skip_requested:
			char_index = character_text.length()
			skip_requested = false
		else:
			if next_char_timer >= next_char_wait:
				next_char_timer = 0.0
				char_index += 1
		if "style" in dialogue_dict[current_dialogue_id]:
			var style = dialogue_dict[current_dialogue_id]["style"]
			response_text.visible = false
		else:
			response_text.text = "[center][color="+text_color+"][i]"+character_text.substr(0,char_index)
			response_text.visible = true
	
	print(response_text.text)
	
	if char_index > character_text.length():
		response_arrow.visible = true
		response_arrow.add_theme_constant_override("margin_bottom", (5 * cos(5 * next_char_timer) + 269))
		if not finished_line:
			finished_line = true
			await get_tree().create_timer(0.5).timeout
			can_advance = true
	# check for and process dialogue if next button (E) is pressed
	if (Input.is_action_just_pressed("interaction")):
		if (char_index <= character_text.length()):
			char_index = character_text.length()
		else:
			if not finished_line:
				skip_requested = true
			else:
				if can_advance:
					can_advance = false
					finished_line = false
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
	char_index = 1
	
	if "next" in dialogue_dict[current_dialogue_id]:
		current_dialogue_id = dialogue_dict[current_dialogue_id]["next"]
	else:
		close_3choice_dialogue()
	
	if current_dialogue_id == "end":	# "next": "end" is end-dialogue keyword in json
		close_3choice_dialogue()
	else:
		next_char_timer = 0.0
		
		response_arrow.visible = false
		# get/set character name and text accordingly from dictionary
		var character_name = dialogue_dict[current_dialogue_id]["name"]
		character_text = dialogue_dict[current_dialogue_id]["text"]["en"]

func close_3choice_dialogue():
	# disable dialogue & interactable, enable player
	target_position = Vector2(0, 300)
	interactable = false
	emit_signal("closed_signal")
	console_complete.emit()
	
	if interacted_area:
		interacted_area.end_interaction()
