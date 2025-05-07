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
	
	if active_element and Input.is_action_just_pressed("menu"):
		close_page_element()
		close_ui()
		active_element = null

func open_ui():
	open_ui_time = 0.
	panel.visible = true

func close_ui():
	close_ui_time = 0.
	panel.visible = true

func open_page_element(element):
	active_element = element
	
	
	open_single_time = 0.
	active_element.visible = true
	
	return
	
	for button in active_element.get_children():
		button.pressed.connect(Callable(mark_button).bind(button))

func close_page_element():
	close_single_time = 0.

func mark_button(button):
	## TOGGLEABLE BUTTON indicates CORRECT CLICK ZONE
	if button.toggle_mode and !button.disabled:
		button.disabled = true
		tiles_found = tiles_found + 1

func interp(start, finish, delta, easing):
	match(easing):
		"linear":
			return start + (finish - start) * (delta)
		"easeOutExpo":
			return start + (finish - start) * (1. - pow(2., -10. * delta))
		"easeInExpo":
			return start + (finish - start) * (pow(2., 10. * delta - 10.))
