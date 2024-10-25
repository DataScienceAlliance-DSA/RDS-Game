extends MarginContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = Vector2(0, 760)
	self.set_process(false)

func _process(_delta):
	var cannon = get_tree().get_first_node_in_group("Cannon");
	
	# move dialogue boxes into position post-open_dialogue
	self.position = self.position.lerp(Vector2(0, 0), _delta * 10)

	# check for and process dialogue if next button (E) is pressed
	if (Input.is_action_just_pressed("interaction")):
		cannon.set_process(true)
		self.set_process(false)
		self.visible = false
