extends MarginContainer

var dialogue_dict = {}		# current dialogue dictionary
var current_dialogue_id		# current dialogue id

var interacted_area

# properties for player character's dialogue box
@onready var player_color = (get_node("PlayerContainer/PositionControl") as CanvasItem)
@onready var player_scale = (get_node("PlayerContainer/PositionControl/ScaleControl") as Control)
@onready var player_avatar = (get_node("PlayerContainer/PositionControl/ScaleControl/IconCenter/PlayerAvatar") as TextureRect)
@onready var player_name = (get_node("PlayerContainer/PositionControl/ScaleControl/Namecont/DialogueText") as RichTextLabel)
@onready var player_text = (get_node("PlayerContainer/PositionControl/ScaleControl/Textcont/DialogueText") as RichTextLabel)

# properties for opposing character's dialogue box
@onready var opposing_color = (get_node("CharacterContainer/PositionControl") as CanvasItem)
@onready var opposing_scale = (get_node("CharacterContainer/PositionControl/ScaleControl") as Control)
@onready var opposing_avatar = (get_node("CharacterContainer/PositionControl/ScaleControl/IconCenter/CharacterAvatar") as TextureRect)
@onready var opposing_name = (get_node("CharacterContainer/PositionControl/ScaleControl/Namecont/DialogueText") as RichTextLabel)
@onready var opposing_text = (get_node("CharacterContainer/PositionControl/ScaleControl/Textcont/DialogueText") as RichTextLabel)

func _ready():
	self.set_process(false)

func open_dialogue(json_path, area):
	# after disabling player & enabling interactable, enable dialogue
	self.visible = true
	self.set_process(true)
	
	# save interactable area for when closing dialogue
	interacted_area = area
	
	# reset player and opposing character text to "..." before dialogue starts
	player_text.text = "[left][color=white][b]...[/b]"
	opposing_text.text = "[right][color=white][b]...[/b]"
	
	# parse dialogue and process first line
	dialogue_dict = parse_dialogue(json_path)
	current_dialogue_id = "root"
	process_next_text()
	self.position.y = 300

func _process(_delta):
	# move dialogue boxes into position post-open_dialogue
	self.position = self.position.lerp(Vector2(0, 0), _delta * 10)
	
	# check for and process dialogue if next button (E) is pressed
	if (Input.is_action_just_pressed("interaction")):
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
	current_dialogue_id = dialogue_dict[current_dialogue_id]["next"]
	
	if current_dialogue_id == "end":	# "next": "end" is end-dialogue keyword in json
		close_dialogue()
	else:
		# get/set character name and text accordingly from dictionary
		var card_name = dialogue_dict[current_dialogue_id]["name"]
		var card_text = dialogue_dict[current_dialogue_id]["text"]["en"]
		
		# if dialogue entry name is not Player, edit right text box of UI
		if (dialogue_dict[current_dialogue_id]["name"] != "Player"):
			opposing_name.text = "[right][color=white][b]"+card_name+"[/b]"
			opposing_text.text = "[right][color=white]"+card_text
			opposing_scale.scale = Vector2(1.4, 1.4)
			opposing_color.modulate.v = 1
			opposing_avatar.texture = load("res://assets/ui_assets/portraits/"+card_name+".PNG")
			
			player_scale.scale = Vector2(1.25, 1.25)
			player_color.modulate.v = 0.5
		# else, edit left text box of UI
		else:
			player_name.text = "[left][color=white][b]"+card_name+"[/b]"
			player_text.text = "[left][color=white]"+card_text
			player_scale.scale = Vector2(1.4, 1.4)
			player_color.modulate.v = 1
			player_avatar.texture = load("res://assets/ui_assets/portraits/"+card_name+".PNG")
			
			opposing_scale.scale = Vector2(1.25, 1.25)
			opposing_color.modulate.v = 0.5

func close_dialogue():
	# disable dialogue & interactable, enable player
	self.visible = false
	self.set_process(false)
	interacted_area.end_interaction()
