extends TextureRect

@onready var active_png = load("res://assets/Fairness_Village/Help Button_Active.png")
@onready var hover_png = load("res://assets/Fairness_Village/Help Button_Hover.png")
@onready var click_png = load("res://assets/Fairness_Village/Help Button_On-Click.png")
@onready var visit_png = load("res://assets/Fairness_Village/Help Button_Visited.png")

enum ui_states {ACTIVE, HOVER, CLICK, VISIT}

var ui_state = ui_states.ACTIVE

var primed
@onready var visited = false

func _process(delta):
	if (primed):
		if (Input.is_action_pressed("left_click")):
			ui_state = ui_states.CLICK
		elif (Input.is_action_just_released("left_click")):
			visited = !visited
		else:
			if (visited):
				modulate = Color(0.945, 0.847, 0.788)
			else:
				modulate = Color(1,1,1)
			ui_state = ui_states.HOVER
	else:
		if (visited):
			ui_state = ui_states.VISIT
		else:
			ui_state = ui_states.ACTIVE
	
	match(ui_state):
		ui_states.ACTIVE:
			texture = active_png
		ui_states.HOVER:
			texture = hover_png
		ui_states.CLICK:
			texture = click_png
		ui_states.VISIT:
			texture = visit_png

func _on_mouse_entered():
	primed = true

func _on_mouse_exited():
	primed = false
