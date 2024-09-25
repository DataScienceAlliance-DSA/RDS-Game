extends MarginContainer

var dialogue_dict = {}		# current dialogue dictionary
var current_dialogue_id		# current dialogue id

var interacted_area

# properties for player character's dialogue box
@onready var player_color = (get_node("PlayerContainer/PositionControl") as CanvasItem)
@onready var player_scale = (get_node("PlayerContainer/PositionControl/ScaleControl") as Control)
@onready var player_avatar = (get_node("PlayerContainer/PositionControl/ScaleControl/IconCenter/Avatar") as TextureRect)
@onready var player_text = (get_node("PlayerContainer/PositionControl/ScaleControl/MarginContainer/DialogueText") as RichTextLabel)

# properties for opposing character's dialogue box
@onready var opposing_color = (get_node("CharacterContainer/PositionControl") as CanvasItem)
@onready var opposing_scale = (get_node("CharacterContainer/PositionControl/ScaleControl") as Control)
@onready var opposing_avatar = (get_node("CharacterContainer/PositionControl/ScaleControl/IconCenter/Avatar") as TextureRect)
@onready var opposing_text = (get_node("CharacterContainer/PositionControl/ScaleControl/MarginContainer/DialogueText") as RichTextLabel)

func _ready():
	self.set_process(false)

func open_dialogue(json_path, area):
	self.visible = true
	self.set_process(true)
	
	interacted_area = area
	
	# reset player and opposing character text to "..." before dialogue starts
	player_text.text = "[color=black][b]...[/b]"
	opposing_text.text = "[color=black][b]...[/b]"
	
	dialogue_dict = parse_dialogue(json_path)
	current_dialogue_id = "root"
	process_next_text()
	self.position.y = 300

func _process(_delta):
	self.position = self.position.lerp(Vector2(0, 0), _delta * 10)
	
	if (Input.is_action_just_pressed("interaction")):
		process_next_text()

func parse_dialogue(json_path):
	if FileAccess.file_exists(json_path):
		var data_file = FileAccess.open(json_path, FileAccess.READ)
		var parsed_result = JSON.parse_string(data_file.get_as_text())
		
		if parsed_result is Dictionary:
			return parsed_result
		else:
			print("Error reading JSON file. Must result in a dictionary.")

func process_next_text():	
	current_dialogue_id = dialogue_dict[current_dialogue_id]["next"]
	
	if current_dialogue_id == "end":	# "next": "end" is end-dialogue keyword in json
		close_dialogue()
	else:
		var name = dialogue_dict[current_dialogue_id]["name"]
		var text = dialogue_dict[current_dialogue_id]["text"]["en"]
		
		# if dialogue entry name is not Player, edit right text box
		if (dialogue_dict[current_dialogue_id]["name"] != "Player"):
			opposing_text.text = "[color=black][b]"+name+"[/b]"+"\n\n"+text
			opposing_scale.scale = Vector2(1.5, 1.5)
			opposing_color.modulate.v = 1
			
			player_scale.scale = Vector2(1.25, 1.25)
			player_color.modulate.v = 0.5
		# else, edit left text box
		else:
			player_text.text = "[color=black][b]"+name+"[/b]"+"\n\n"+text
			player_scale.scale = Vector2(1.5, 1.5)
			player_color.modulate.v = 1
			
			opposing_scale.scale = Vector2(1.25, 1.25)
			opposing_color.modulate.v = 0.5

func close_dialogue():
	self.visible = false
	self.set_process(false)
	interacted_area.end_interaction()
