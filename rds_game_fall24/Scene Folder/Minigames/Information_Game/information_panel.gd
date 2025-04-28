extends CanvasLayer

@onready var panel = $Panel
@onready var panel_sm = $Panel.material

@onready var single_ctrl = $Panel/SingleElement
var active_element

# MAX VISUAL TIMES
@export var open_ui_max : float
@export var open_single_max : float
@export var close_single_max : float
@export var close_ui_max : float

# ACTIVE VISUAL TIMES
@onready var open_ui_time = open_ui_max
@onready var open_single_time = open_single_max
@onready var close_single_time = close_single_max
@onready var close_ui_time = close_ui_max

@onready var memory_game_starting = false
@onready var memory_timer = 0.

# VISUAL COMPLETION SIGNALS
signal ui_opened
signal single_element_opened
signal single_element_closed
signal ui_closed

# GAME LOGIC SIGNALS
signal stage_condition_passed

# GAME LOGIC
@onready var game_stage = 10
## PII PHASE
@onready var pii_present = 0 # total # of pii present in document
@onready var pii_found = 0 # total # of pii correctly selected
## MEMORY PHASE
@onready var tiles_present = 0
@onready var tiles_found = 0
## ENCRYPTION PHASE
@onready var texts_present = 0
@onready var texts_complete = 0
@onready var active_text_button = null
@onready var active_text_box = null

func _process(delta):
	## VISUAL PROCESSES:
	# opening panel blur
	if (open_ui_time < open_ui_max):
		open_ui_time = open_ui_time + delta
		if open_ui_time > open_ui_max: ui_opened.emit()
		var t = open_ui_time / open_ui_max
		
		panel_sm.set_shader_parameter('lod', interp(0., 1.5, t, 'linear'))
		panel_sm.set_shader_parameter('dim', interp(0., .15, t, 'linear'))
	if (close_ui_time < close_ui_max):
		close_ui_time = close_ui_time + delta
		if close_ui_time > close_ui_max: 
			ui_closed.emit()
			panel.visible = false
		var t = close_ui_time / close_ui_max
		
		panel_sm.set_shader_parameter('lod', interp(1.5, 0., t, 'linear'))
		panel_sm.set_shader_parameter('dim', interp(.15, 0., t, 'linear'))
	# opening a single element in panel
	if (open_single_time < open_single_max):
		open_single_time = open_single_time + delta
		if open_single_time > open_single_max: single_element_opened.emit()
		var t = open_single_time / open_single_max
		
		single_ctrl.position.y = interp(768., 0., t, 'easeOutExpo')
		single_ctrl.scale.y = interp(0., 1., t, 'easeOutExpo')
		var c = interp(.2, 1., t, 'easeOutExpo')
		single_ctrl.modulate = Color(c,c,c,1.)
	# closing a single element in panel
	if (close_single_time < close_single_max):
		close_single_time = close_single_time + delta
		if close_single_time > close_single_max: single_element_closed.emit()
		var t = close_single_time / close_single_max
		
		single_ctrl.position.y = interp(0., 768., t, 'easeInExpo')
		single_ctrl.scale.y = interp(1., 0., t, 'easeInExpo')
		var c = interp(1., .2, t, 'easeInExpo')
		single_ctrl.modulate = Color(c,c,c,1.)
	
	if game_stage >= 7 and game_stage <= 9:
		memory_timer = memory_timer + delta
		if memory_timer < 5.:
			for button in active_element.get_child(0).get_children():
				button.disabled = true
				if button.toggle_mode:
					var sb = button.get_theme_stylebox("disabled").duplicate()
					var ca = interp(.466, .6, memory_timer / 5., 'easeInExpo')
					var cb = interp(.592, .6, memory_timer / 5., 'easeInExpo')
					var cd = interp(.882, .6, memory_timer / 5., 'easeInExpo')
					sb.bg_color = Color(ca, cb, cd, 1.)
					button.add_theme_stylebox_override("disabled", sb)
				else:
					var sb = button.get_theme_stylebox("disabled").duplicate()
					sb.bg_color = Color(.6, .6, .6, 1.)
					button.add_theme_stylebox_override("disabled", sb)
		elif memory_game_starting:
			memory_game_starting = false
			for button in active_element.get_child(0).get_children():
				button.disabled = false
				var sbd = button.get_theme_stylebox("disabled").duplicate()
				sbd.bg_color = Color(.466, .592, .882, 1.)
				var sbh = button.get_theme_stylebox("hover").duplicate()
				sbh.bg_color = Color(.847, .847, .847, 1.)
				var sbn = button.get_theme_stylebox("normal").duplicate()
				sbn.bg_color = Color(.6, .6, .6, 1.)
				var sbp = button.get_theme_stylebox("pressed").duplicate()
				sbp.bg_color = Color(.309, .309, .309, 1.)
				button.add_theme_stylebox_override("disabled", sbd)
				button.add_theme_stylebox_override("hover", sbh)
				button.add_theme_stylebox_override("normal", sbn)
				button.add_theme_stylebox_override("pressed", sbp)

func _input(event):
	## TEXT LOGIC PROCESS FOR TEXTBOXES IN ENCRYPTION PHASE:
	if !(game_stage >= 4 and game_stage <= 6): return
	
	if event is InputEventKey and event.pressed:
		var scancode = event.physical_keycode
		var new_key = OS.get_keycode_string(scancode)
		var char = ""
		
		var acceptable_chars = [
			"A","B","C","D","E","F","G","H","I","J","K","L","M",
			"N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
			"0","1","2","3","4","5","6","7","8","9"
		]
		
		if new_key == "Space":
			char = " "
		
		if acceptable_chars.has(new_key):
			var is_shift_held = Input.is_key_pressed(KEY_SHIFT)
			if !is_shift_held:
				char = new_key.to_lower()
			else:
				char = new_key
		
		if active_text_button:
			if !active_text_button.disabled:
				var bad_text = false
				var current = active_text_box.text.substr(21, len(active_text_box.text) - 1)
				if active_text_button.name.contains(current) or (len(current) == 0): bad_text = false
				else: bad_text = true
				
				if !bad_text:
					var check_string = active_text_box.text + char
					var check_now = check_string.substr(21, len(check_string) - 1)
					var answer_compare_ref = active_text_button.name.substr(0, len(check_now))
					print(answer_compare_ref)
					print(check_now)
					if (answer_compare_ref == check_now):
						active_text_box.text += char
					else:
						active_text_box.text += "[color=red]" + char
				
				current = active_text_box.text.substr(21, len(active_text_box.text) - 1)
				if active_text_button.name == current:
					active_text_box.text = "[center][color=green]" + active_text_button.name
					active_text_button.disabled = true
					texts_complete = texts_complete + 1
				
				if !active_text_box.text == "[center][color=black]":
					if new_key == "Backspace":
						if bad_text:
							active_text_box.text = active_text_box.text.substr(0, len(active_text_box.text) - 12)
							bad_text = false
						else:
							active_text_box.text = active_text_box.text.substr(0, len(active_text_box.text) - 1)

func stage_condition_check():
	if game_stage >= 1 and game_stage <= 3: 
		if pii_found == pii_present:
			stage_condition_passed.emit()
	elif game_stage >= 4 and game_stage <= 6:
		if texts_complete == texts_present:
			stage_condition_passed.emit()
	elif game_stage >= 7 and game_stage <= 9:
		if tiles_found == tiles_present:
			stage_condition_passed.emit()

func next_stage():
	if active_element: active_element.visible = false
	
	pii_found = 0
	tiles_found = 0
	texts_complete = 0
	game_stage = game_stage + 1
	
	match(game_stage):
		1:
			pii_present = 3
		2:
			pii_present = 1
		3:
			pii_present = 2
		4:
			texts_present = 3
		5:
			texts_present = 1
		6:
			texts_present = 2
		7:
			tiles_present = 12
		8:
			tiles_present = 11
		9:
			tiles_present = 13
	
	open_page_element()

func open_ui():
	open_ui_time = 0.
	panel.visible = true

func close_ui():
	close_ui_time = 0.
	panel.visible = true

func open_page_element():
	match(game_stage):
		1:
			active_element = $Panel/SingleElement/OfferLetter
		2:
			active_element = $Panel/SingleElement/PrivateText
		3:
			active_element = $Panel/SingleElement/DeliveryReceipt
		4:
			active_element = $Panel/SingleElement/Encryption1
		5:
			active_element = $Panel/SingleElement/Encryption2
		6:
			active_element = $Panel/SingleElement/Encryption3
		7:
			active_element = $Panel/SingleElement/Memory1
		8:
			active_element = $Panel/SingleElement/Memory2
		9:
			active_element = $Panel/SingleElement/Memory3
	
	if game_stage < 4:
		for button in active_element.get_children():
			button.pressed.connect(Callable(assess_button).bind(button))
	elif game_stage >= 4 and game_stage <= 6:
		for button in active_element.get_node("TextureRect2/VBoxContainer/RichTextLabel").get_children():
			if button.name == "Hero": button.name = encode_custom_cipher(GlobalPlayerName.global_player_name) # button names are used as the correct decryption answer
			button.pressed.connect(Callable(select_button).bind(button))
	elif game_stage >= 7 and game_stage <= 9:
		memory_timer = 0.
		memory_game_starting = true
		for button in active_element.get_child(0).get_children():
			button.pressed.connect(Callable(mark_button).bind(button))
	
	open_single_time = 0.
	active_element.visible = true

func close_page_element():
	close_single_time = 0.

# button action for the PII stages
func assess_button(button):
	## TOGGLEABLE BUTTON indicates CORRECT CLICK ZONE
	if button.toggle_mode:
		button.disabled = true
		button.modulate = Color(0.,1.,0.,1.)
		pii_found = pii_found + 1

func mark_button(button):
	## TOGGLEABLE BUTTON indicates CORRECT CLICK ZONE
	if button.toggle_mode and !button.disabled:
		button.disabled = true
		tiles_found = tiles_found + 1

func select_button(button):
	## TOGGLEABLE BUTTON indicates CORRECT CLICK ZONE
	active_text_button = button
	active_text_box = button.get_node("VBoxContainer/RichTextLabel")
	print(active_text_box.name)

func encode_custom_cipher(text: String) -> String:
	var result := ""
	for c in text:
		var code := c.unicode_at(0)
		
		# Handle uppercase letters
		if code >= 65 and code <= 90: # 'A' to 'Z'
			var new_code = 65 + (90 - code)
			result += char(new_code)
		
		# Handle lowercase letters
		elif code >= 97 and code <= 122: # 'a' to 'z'
			var new_code = 97 + (122 - code)
			result += char(new_code)
		
		# Handle digits
		elif code >= 48 and code <= 57: # '0' to '9'
			var num = (code - 48 + 2) % 10
			result += str(num)
		
		# Leave other characters unchanged
		else:
			result += c
	
	return result

func interp(start, finish, delta, easing):
	match(easing):
		"linear":
			return start + (finish - start) * (delta)
		"easeOutExpo":
			return start + (finish - start) * (1. - pow(2., -10. * delta))
		"easeInExpo":
			return start + (finish - start) * (pow(2., 10. * delta - 10.))
