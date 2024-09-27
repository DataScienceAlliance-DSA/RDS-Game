extends MarginContainer

var dialogue_dict = {}		# current dialogue dictionary
var current_dialogue_id		# current dialogue id

var interacted_area

# properties for player character's dialogue box

# properties for opposing character's dialogue box
@onready var text_scale = (get_node("TextContainer/PositionControl/ScaleControl") as Control)
@onready var text_avatar = (get_node("TextContainer/PositionControl/ScaleControl/IconCenter/Avatar") as TextureRect)
@onready var text = (get_node("TextContainer/PositionControl/ScaleControl/MarginContainer/MonologueText") as RichTextLabel)

func _ready():
	self.set_process(false)

func open_monologue(json_path, area):
	# after disabling player & enabling interactable, enable dialogue
	self.visible = true
	self.set_process(true)
	
	# save interactable area for when closing dialogue
	interacted_area = area
	
	# reset player and opposing character text to "..." before dialogue starts
	text.text = "[color=black][b]...[/b]"
	
	# parse dialogue and process first line
	dialogue_dict = parse_monologue(json_path)
	current_dialogue_id = "root"
	process_next_text()
	self.position.y = 300

func parse_monologue(json_path):
	# .json parseing magic a la GDscript manual
	if FileAccess.file_exists(json_path):
		var data_file = FileAccess.open(json_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		
		if parsed_result is Dictionary:
			return parsed_result
		else:
			print("Error reading JSON file. Must result in a dictionary.")

func process_next_text():
	pass
