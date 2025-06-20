extends CanvasLayer

var top_panels : Array[Control]
var bottom_panels : Array[Control]

var top_open_checks : Array[bool]
var bottom_open_checks : Array[bool]

func _ready():
	var top_container = $Control/MarginContainer/VBoxContainer/HBoxContainer
	var bottom_container = $Control/MarginContainer/VBoxContainer/HBoxContainer2
	top_panels = [top_container.get_node("Panel"), top_container.get_node("Panel2"), top_container.get_node("Panel3"), top_container.get_node("Panel4")]
	bottom_panels = [bottom_container.get_node("Panel"), bottom_container.get_node("Panel2"), bottom_container.get_node("Panel3"), bottom_container.get_node("Panel4")]
	
	top_open_checks = [true, true, true, false]
	bottom_open_checks = [true, true, false, true]

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

func debug_collapsed_panel(panel : Panel):
	panel.set_stretch_ratio(0.)
	panel.get_node("TextureRect").scale.x = 0.
