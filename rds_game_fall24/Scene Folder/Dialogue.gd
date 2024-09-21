extends MarginContainer

func _ready():
	self.set_process(false)

func open_dialogue(character):
	self.set_process(true)
	self.position.y = 300

func _process(_delta):
	self.position = self.position.lerp(Vector2(0, 0), _delta * 10)
