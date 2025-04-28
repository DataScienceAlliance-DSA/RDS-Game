extends Node2D

var active_bubble
@onready var panel = $BubblePanel

func _ready():
	for bubble in $Bubbles.get_children():
		bubble.set_root(self)

func _process(delta):
	print(str(active_bubble) + "    " + str(Input.is_action_just_pressed("left_click")))
	
	if active_bubble and Input.is_action_just_pressed("left_click"):
		panel.open_ui()
		panel.open_page_element(active_bubble.connected_panel_element)
