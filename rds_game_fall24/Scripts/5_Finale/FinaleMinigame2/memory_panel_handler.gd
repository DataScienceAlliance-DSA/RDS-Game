extends CanvasLayer

var top_panels : Array[Control]
var bottom_panels : Array[Control]

var top_open_checks : Array[bool]
var bottom_open_checks : Array[bool]

@onready var wrong_match_triggered = false
@onready var wrong_match_timer = 0.

var wrong_match_A
var wrong_match_B
var wrong_match_A_pos
var wrong_match_B_pos

## GAME LOGIC VARIABLES
var clicked_panels: Array = []

@onready var game_paused = false
@onready var game_tally = 0 # game finished at 4

var cm : CutsceneManager

signal game_complete

func _ready():
	set_process(false)

func run_memory_game():
	var top_container = $Control/MarginContainer/VBoxContainer/HBoxContainer
	var bottom_container = $Control/MarginContainer/VBoxContainer/HBoxContainer2
	top_panels = [top_container.get_node("Panel"), top_container.get_node("Panel2"), top_container.get_node("Panel3"), top_container.get_node("Panel4")]
	bottom_panels = [bottom_container.get_node("Panel"), bottom_container.get_node("Panel2"), bottom_container.get_node("Panel3"), bottom_container.get_node("Panel4")]
	
	top_open_checks = [true, true, true, true]
	bottom_open_checks = [true, true, true, true]
	
	for panel in top_panels + bottom_panels:
		var texture_rect = panel.get_node("TextureRect")
		var button = texture_rect.get_node("Button")
		
		button.mouse_entered.connect(on_hover_entered.bind(texture_rect))
		button.mouse_exited.connect(on_hover_exited.bind(texture_rect))
		button.pressed.connect(on_panel_clicked.bind(panel))
	
	var actions : Array[Action] = []
	cm = CutsceneManager.new(actions)
	
	set_process(true)
	
	game_paused = true
	cm.call_monologue("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame2/MemoryIntro.json")
	await cm.lines_complete
	game_paused = false

func on_hover_entered(texture_rect: TextureRect) -> void:
	texture_rect.scale = Vector2(1.1, 1.1)

func on_hover_exited(texture_rect: TextureRect) -> void:
	texture_rect.scale = Vector2(1.0, 1.0)

func on_panel_clicked(panel: Control) -> void:
	if game_paused: return
	
	if clicked_panels.has(panel): 
		return
	
	if clicked_panels.size() > 0:
		if (top_panels.has(clicked_panels[0]) and top_panels.has(panel)) or (bottom_panels.has(clicked_panels[0]) and bottom_panels.has(panel)):
			clicked_panels[0] = panel
			return
	
	var tween = create_tween()
	var panel_panel = panel.get_children()[0].get_children()[0]
	tween.tween_property(panel_panel, "modulate", Color.WEB_GRAY, 0.25)
	
	clicked_panels.append(panel)
	if clicked_panels.size() == 2:
		var first = clicked_panels[0]
		var second = clicked_panels[1]
		
		if first.editor_description != second.editor_description:
			incorrect_match(first, second)
		else:
			correct_match(first, second)
			game_tally = game_tally + 1
			
			var text
			
			match(first.editor_description):
				"Fairness":
					text = ("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame2/Memory1.json")
				"Transparency":
					text = ("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame2/MemoryTransparency.json")
				"Privacy":
					text = ("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame2/MemoryPrivacy.json")
				"Veracity":
					text = ("res://Resources/Texts/Dialogues/5_Finale/FinaleMinigame2/MemoryVeracity.json")
			
			cm.call_monologue(text)
			game_paused = true
			await cm.lines_complete
			
			clicked_panels[0].visible = false
			clicked_panels[1].visible = false
			clicked_panels[0] = null
			clicked_panels[1] = null
			
			game_paused = false
			
			if (game_tally == 4):
				game_complete.emit()
		
		clicked_panels.clear()

func set_group_incorrect(panelA, panelB):
	wrong_match_triggered = true
	wrong_match_A = panelA.get_children()[0].get_children()[0]
	wrong_match_B = panelB.get_children()[0].get_children()[0]
	wrong_match_A_pos = wrong_match_A.global_position
	wrong_match_B_pos = wrong_match_B.global_position

func _process(delta):
	for i in range(4):
		if !top_open_checks[i]:
			var panel = top_panels[i]
			var texture = panel.get_node("TextureRect")
			
			panel.set_stretch_ratio(lerpf(panel.get_stretch_ratio(), 0., delta * 7.))
			texture.scale.x = lerpf(texture.scale.x, 0., delta * 7.)
		if !bottom_open_checks[i]:
			var panel = bottom_panels[i]
			var texture = panel.get_node("TextureRect")
			
			panel.set_stretch_ratio(lerpf(panel.get_stretch_ratio(), 0., delta * 7.))
			texture.scale.x = lerpf(texture.scale.x, 0., delta * 7.)

func incorrect_match(panel_A, panel_B):
	var tween_A = create_tween()
	var panel_panel_A = panel_A.get_children()[0].get_children()[0]
	tween_A.tween_property(panel_panel_A, "modulate", Color.RED, 0.25)
	tween_A.tween_property(panel_panel_A, "modulate", Color.RED, 0.25)
	tween_A.tween_property(panel_panel_A, "modulate", Color.WHITE, 0.75)
	
	var tween_B = create_tween()
	var panel_panel_B = panel_B.get_children()[0].get_children()[0]
	tween_B.tween_property(panel_panel_B, "modulate", Color.RED, 0.25)
	tween_B.tween_property(panel_panel_B, "modulate", Color.RED, 0.25)
	tween_B.tween_property(panel_panel_B, "modulate", Color.WHITE, 0.75)

func correct_match(panel_A, panel_B):
	var tween_A = create_tween()
	var panel_panel_A = panel_A.get_children()[0].get_children()[0]
	tween_A.tween_property(panel_panel_A, "modulate", Color.GREEN, 0.25)
	tween_A.tween_property(panel_panel_A, "modulate", Color.GREEN, 0.25)
	tween_A.tween_property(panel_panel_A, "modulate", Color.WHITE, 0.75)
	
	var tween_B = create_tween()
	var panel_panel_B = panel_B.get_children()[0].get_children()[0]
	tween_B.tween_property(panel_panel_B, "modulate", Color.GREEN, 0.25)
	tween_B.tween_property(panel_panel_B, "modulate", Color.GREEN, 0.25)
	tween_B.tween_property(panel_panel_B, "modulate", Color.WHITE, 0.75)
	
	if panel_A.get_parent() == $Control/MarginContainer/VBoxContainer/HBoxContainer:
		top_open_checks[get_panel_index(panel_A)] = false
		bottom_open_checks[get_panel_index(panel_B)] = false
	else:
		bottom_open_checks[get_panel_index(panel_A)] = false
		top_open_checks[get_panel_index(panel_B)] = false
	
	panel_A.get_node("TextureRect/Button").queue_free()
	panel_B.get_node("TextureRect/Button").queue_free()
	panel_A.get_node("TextureRect").scale = Vector2(1., 1.)
	panel_B.get_node("TextureRect").scale = Vector2(1., 1.)

func get_panel_index(panel: Control) -> int:
	var name = panel.name  # e.g., "Panel", "Panel2", ...
	if name == "Panel":
		return 0
	else:
		var suffix = name.substr(5)  # Extracts the number after "Panel"
		return int(suffix) - 1  # "Panel2" → 1, etc.
