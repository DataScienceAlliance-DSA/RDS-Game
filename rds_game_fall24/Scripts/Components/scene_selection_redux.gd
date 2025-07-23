extends Node

@onready var chapter_container: VBoxContainer = $CanvasLayer/MarginContainer/VBoxContainer/Panel4/HBoxContainer/Panel3/VBoxContainer
@onready var chapter_items: VBoxContainer = $"CanvasLayer/MarginContainer/VBoxContainer/Panel4/HBoxContainer/Panel/MarginContainer/HBoxContainer/Panel2/VBoxContainer"

var chapter_title_buttons : Array = []
var minigame_buttons: Array = []
var chapter_index := 0
const MAX_INDEX := 5
var target_y := 0.0

var item_height := 0.0
var v_sep := 0.0

@onready var target_chapter_container_pos = Vector2(0.,0.)

var chapter_buttons: Array = []
var all_scene_buttons: Array = []

# MAC OS TRACKPAD GESTURES
var scroll_accum = 0.
const SCROLL_TRIGGER = 1.5

func _ready():
	UI.start_scene_change(false, false, "")
	UI.set_tooltip("")
	PS.reset_states()
	call_deferred("_calculate_item_size")
	call_deferred("_gather_minigame_buttons")
	call_deferred("_gather_all_buttons")
	call_deferred("_gather_chapter_title_buttons")

func _gather_chapter_title_buttons():
	chapter_title_buttons.clear()
	
	for i in chapter_items.get_child_count():
		var panel = chapter_items.get_child(i)
		var button = panel.get_child(0).get_child(0)
		chapter_title_buttons.append(button)
		
		# Store the panel for scaling later (so we don’t have to traverse again)
		button.set_meta("scale_target", panel)
		button.set_meta("index", i)
		button.set_meta("hovering", false)
		
		button.mouse_entered.connect(_on_chapter_title_hover.bind(button))
		button.mouse_exited.connect(_on_chapter_title_unhover.bind(button))
		button.pressed.connect(_on_chapter_title_pressed.bind(button))

func _on_chapter_title_hover(button):
	button.set_meta("hovering", true)

func _on_chapter_title_unhover(button):
	button.set_meta("hovering", false)

func _on_chapter_title_pressed(button):
	if button.get_meta("index") > chapter_index:
		while (chapter_index != button.get_meta("index")):
			handle_scroll_down()
	if button.get_meta("index") < chapter_index:
		while (chapter_index != button.get_meta("index")):
			handle_scroll_up()

func _on_scene_button_pressed(index: int):
	match index:
		1:
			UI.start_scene_change(true, true, "res://Scenes/0_Tutorial/Tutorial_VeracityEnv/new_library.tscn")
		2:
			UI.start_scene_change(true, true, "res://Scenes/0_Tutorial/TutorialMinigame1/Cannonball_Game.tscn")
		3:
			UI.start_scene_change(true, true, "res://Scenes/0_Tutorial/TutorialMinigame2/GameManager/Mixing_Game.tscn")
		4:
			UI.start_scene_change(true, true, "res://Scenes/1_Fairness/FairnessEnv/fairness_village.tscn")
		5:
			UI.start_scene_change(true, true, "res://Scenes/1_Fairness/FairnessMinigame1/GameManager/fairness_minigame_1.tscn")
		6:
			UI.start_scene_change(true, true, "res://Scenes/1_Fairness/FairnessMinigame2/GameManager/fairness_minigame_2.tscn")
		7:
			print("TRANSPARENCY PILLAR IS WIP")
		8:
			UI.start_scene_change(true, true, "res://Scenes/2_Transparency/TransparencyMinigame1/Cargo_Game.tscn")
		9:
			UI.start_scene_change(true, true, "res://Scenes/2_Transparency/TransparencyMinigame2/transparency_game_2.tscn")
		10:
			print("PRIVACY PILLAR IS WIP")
		11:
			UI.start_scene_change(true, true, "res://Scenes/3_Privacy/PrivacyMinigame1/Information_Game/information_game.tscn")
		12:
			print("SECURITY GAME IS WIP")
		13:
			print("VERACITY PILLAR IS WIP")
		14:
			print("MAP GAME IS WIP")
		15:
			UI.start_scene_change(true, true, "res://Scenes/4_Veracity/VeracityMinigame2/VeracityMinigame2.tscn")
		16:
			PS.dungeon_state = 0
			UI.start_scene_change(true, true, "res://Scenes/5_Finale/FinaleMinigame1/FinaleMinigame1.tscn")
		17:
			PS.dungeon_state = 1
			UI.start_scene_change(true, true, "res://Scenes/5_Finale/FinaleMinigame1/FinaleMinigame1.tscn")
		18:
			PS.dungeon_state = 2
			UI.start_scene_change(true, true, "res://Scenes/5_Finale/FinaleMinigame1/FinaleMinigame1.tscn")

func handle_scroll_down():
	chapter_index = min(chapter_index + 1, MAX_INDEX)
	target_chapter_container_pos = Vector2(chapter_container.position.x, -chapter_index * (item_height + v_sep))

func handle_scroll_up():
	chapter_index = max(chapter_index - 1, 0)
	target_chapter_container_pos = Vector2(chapter_container.position.x, -chapter_index * (item_height + v_sep))

func _unhandled_input(event):
	if event is InputEventPanGesture:
		scroll_accum += event.delta.y
		if scroll_accum > SCROLL_TRIGGER:
			scroll_accum = 0
			handle_scroll_up()
		elif scroll_accum < -SCROLL_TRIGGER:
			scroll_accum = 0
			handle_scroll_down()

func _process(delta):
	if (Input.is_action_just_pressed("down") or Input.is_action_just_pressed("scroll_down")): 
		handle_scroll_down()
	elif (Input.is_action_just_pressed("up") or Input.is_action_just_pressed("scroll_up")): 
		handle_scroll_up()
	
	chapter_container.position = chapter_container.position.lerp(target_chapter_container_pos, 10 * delta)
	
	for i in chapter_items.get_child_count():
		var item = chapter_items.get_child(i)
		if item.get_child_count() == 0:
			continue
		var label = item.get_child(0)
		if not label is RichTextLabel:
			continue
		
		var item_button = item.get_child(0).get_child(0) #RichTextLabel/Button
		
		var target_scale
		if (i == chapter_index):
			target_scale = Vector2.ONE
		elif (item_button.get_meta("hovering")):
			target_scale = Vector2(.95,.95)
		else:
			target_scale = Vector2(0.9,0.9)
		
		var target_modulate = Color.WHITE if (i == chapter_index) else Color8(200, 200, 200)
		
		label.scale = label.scale.lerp(target_scale, 8 * delta)
		label.modulate = label.modulate.lerp(target_modulate, 8 * delta)
	
	# Highlight the selected child in chapter_container
	for i in chapter_container.get_child_count():
		var child = chapter_container.get_child(i)
		if not child is Control:
			continue
		
		var target_modulate = Color8(255, 255, 255) if (i == chapter_index) else Color8(150, 150, 150)
		child.modulate = child.modulate.lerp(target_modulate, 8 * delta)
	
	for button in minigame_buttons:
		if not button is Control:
			continue
		var is_hovered = button.get_rect().has_point(button.get_local_mouse_position())
		var target_scale = Vector2(1.05, 1.05) if is_hovered else Vector2.ONE
		button.scale = button.scale.lerp(target_scale, 10 * delta)

func _gather_all_buttons():
	chapter_buttons.clear()
	all_scene_buttons.clear()

	# Step 1: Gather chapter buttons
	for chapter in chapter_container.get_children():
		var path = "VBoxContainer/Panel/HBoxContainer/Panel2/MarginContainer/TextureButton"
		if chapter.has_node(path):
			var chapter_button = chapter.get_node(path)
			chapter_button.mouse_default_cursor_shape = 2
			chapter_button.mouse_filter = 0
			chapter_buttons.append(chapter_button)

	# Step 2: Interleave chapter + minigame buttons
	var chapter_idx := 0
	var minigame_idx := 0

	while chapter_idx < chapter_buttons.size() or minigame_idx < minigame_buttons.size():
		if chapter_idx < chapter_buttons.size():
			all_scene_buttons.append(chapter_buttons[chapter_idx])
			chapter_idx += 1
		if minigame_idx + 1 < minigame_buttons.size():
			all_scene_buttons.append(minigame_buttons[minigame_idx])
			all_scene_buttons.append(minigame_buttons[minigame_idx + 1])
			minigame_idx += 2

	# Step 3: Connect buttons
	for i in all_scene_buttons.size():
		var btn = all_scene_buttons[i]
		btn.pressed.connect(_on_scene_button_pressed.bind(i + 1))  # 1-based

func _calculate_item_size():
	if chapter_container.get_child_count() > 0:
		var first_child = chapter_container.get_child(0)
		item_height = first_child.size.y
		v_sep = chapter_container.get("theme_override_constants/separation") # Or .get_theme_constant("separation")
		target_y = chapter_container.position.y

func _gather_minigame_buttons():
	minigame_buttons.clear()
	for chapter in chapter_container.get_children():
		var button_row = chapter.get_node("VBoxContainer/Panel3/HBoxContainer")
		for subcontainer in button_row.get_children():
			var minigame_button = subcontainer.get_node("VBoxContainer/Panel/TextureButton")
			minigame_button.pivot_offset = minigame_button.size / 2
			minigame_buttons.append(minigame_button)
			minigame_button.mouse_default_cursor_shape = 2
			minigame_button.mouse_filter = 0

