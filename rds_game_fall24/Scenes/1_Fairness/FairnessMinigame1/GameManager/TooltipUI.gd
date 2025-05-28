extends TextureRect

@onready var active_png = load("res://Assets/1_Fairness/FairnessEnv/Help Button_Active.png")
@onready var hover_png = load("res://Assets/1_Fairness/FairnessEnv/Help Button_Hover.png")
@onready var click_png = load("res://Assets/1_Fairness/FairnessEnv/Help Button_On-Click.png")
@onready var visit_png = load("res://Assets/1_Fairness/FairnessEnv/Help Button_Visited.png")

enum ui_states {ACTIVE, HOVER, CLICK, VISIT}
var ui_state = ui_states.ACTIVE

var primed
@onready var visited = false

@onready var tooltip = get_tree().get_nodes_in_group("Tooltip")[0].get_node("Control/TextureRect")
var tooltip_target_pos
@onready var screenblur_mat = get_tree().get_nodes_in_group("ScreenBlur")[0].material

@onready var minigame_controller = get_tree().get_nodes_in_group("MinigameController")[0]

func _process(delta):
	if (primed):
		if (Input.is_action_pressed("left_click")):
			ui_state = ui_states.CLICK
		elif (Input.is_action_just_released("left_click")):
			visited = !visited
			if (visited): minigame_controller.pause_game()
			else: minigame_controller.resume_game()
		else:
			if (visited):
				modulate = Color(0.607,0.411,0.411)
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
	
	tooltip_target_pos = Vector2(-1752,-1752) if visited else Vector2(-1752, -981.)
	print(tooltip.position)
	var screenblur_target_LOD = 0.75 if visited else 0.0
	var screenblur_target_dim = 0.075 if visited else 0.0
	
	tooltip.position = tooltip.position.lerp(tooltip_target_pos, delta * 5.)
	var screenblur_lod = screenblur_mat.get_shader_parameter("lod")
	var screenblur_dim = screenblur_mat.get_shader_parameter("dim")
	
	screenblur_mat.set_shader_parameter("lod", lerpf(screenblur_lod, screenblur_target_LOD, delta * 5.))
	screenblur_mat.set_shader_parameter("dim", lerpf(screenblur_dim, screenblur_target_dim, delta * 5.))

func _on_mouse_entered():
	primed = true

func _on_mouse_exited():
	primed = false
