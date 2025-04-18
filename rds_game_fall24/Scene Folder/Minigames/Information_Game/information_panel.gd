extends CanvasLayer

@onready var panel_sm = $Panel.material

@export var open_ui_max : float

@onready var open_ui_time = open_ui_max

func _process(delta):
	if (open_ui_time < open_ui_max):
		open_ui_time = open_ui_time + delta
		
		var lod = 1.5 * (open_ui_time / open_ui_max)
		var dim = .15 * (open_ui_time / open_ui_max)
		panel_sm.set_shader_parameter('lod', lod)
		panel_sm.set_shader_parameter('dim', dim)

func open_ui():
	open_ui_time = 0.
