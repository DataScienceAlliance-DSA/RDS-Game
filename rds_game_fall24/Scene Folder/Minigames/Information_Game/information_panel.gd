extends CanvasLayer

@onready var panel = $Panel
@onready var panel_sm = $Panel.material

@onready var single_ctrl = $Panel/SingleElement
var active_element

# MAX VISUAL TIMES
@export var open_ui_max : float
@export var open_single_max : float
@export var close_single_max : float

# ACTIVE VISUAL TIMES
@onready var open_ui_time = open_ui_max
@onready var open_single_time = open_single_max
@onready var close_single_time = close_single_max

# VISUAL COMPLETION SIGNALS
signal ui_opened
signal single_element_opened
signal single_element_closed

# GAME LOGIC SIGNALS
signal stage_condition_passed

# GAME LOGIC
@onready var game_stage = 0
## PII PHASE
@onready var pii_present = 0 # total # of pii present in document
@onready var pii_found = 0 # total # of pii correctly selected

func _process(delta):
	## VISUAL PROCESSES:
	# opening panel blur
	if (open_ui_time < open_ui_max):
		open_ui_time = open_ui_time + delta
		if open_ui_time > open_ui_max: ui_opened.emit()
		var t = open_ui_time / open_ui_max
		
		panel_sm.set_shader_parameter('lod', interp(0., 1.5, t, 'linear'))
		panel_sm.set_shader_parameter('dim', interp(0., .15, t, 'linear'))
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

func stage_condition_check():
	if game_stage >= 1 and game_stage <= 3: 
		if pii_found == pii_present:
			stage_condition_passed.emit()

func next_stage():
	if active_element: active_element.visible = false
	
	pii_found = 0
	game_stage = game_stage + 1
	
	match(game_stage):
		1:
			pii_present = 3
		2:
			pii_present = 1
		3:
			pii_present = 2
	
	if game_stage >= 1 and game_stage <= 3: open_page_element()

func open_ui():
	open_ui_time = 0.
	panel.visible = true

func open_page_element():
	match(game_stage):
		1:
			active_element = $Panel/SingleElement/OfferLetter
		2:
			active_element = $Panel/SingleElement/PrivateText
		3:
			active_element = $Panel/SingleElement/DeliveryReceipt
	
	for button in active_element.get_children():
		button.pressed.connect(Callable(assess_button).bind(button))
	
	open_single_time = 0.
	active_element.visible = true

func close_page_element():
	close_single_time = 0.

func assess_button(button):
	## TOGGLEABLE BUTTON indicates CORRECT CLICK ZONE
	if button.toggle_mode:
		print("GOOD")
		button.disabled = true
		button.modulate = Color(0.,1.,0.,1.)
		pii_found = pii_found + 1
	else:
		print("WRONG")

func interp(start, finish, delta, easing):
	match(easing):
		"linear":
			return start + (finish - start) * (delta)
		"easeOutExpo":
			return start + (finish - start) * (1. - pow(2., -10. * delta))
		"easeInExpo":
			return start + (finish - start) * (pow(2., 10. * delta - 10.))
