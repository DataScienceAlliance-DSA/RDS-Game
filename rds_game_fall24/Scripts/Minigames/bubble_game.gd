extends Node2D

var active_bubble
@onready var panel = $BubblePanel

var cm : CutsceneManager

@onready var player = get_tree().get_nodes_in_group("Player")[0]

func _ready():
	player.get_node("Camera2D").limit_bottom = 1344.
	UI.start_scene_change(false, true, "")
	player.autonomous = false
	
	for bubble in $Bubbles.get_children():
		bubble.set_root(self)

func _process(delta):
	if active_bubble and Input.is_action_just_pressed("left_click"):
		panel.open_ui()
		panel.open_page_element(active_bubble.connected_panel_element)

func _on_initiate_cutscene_area_body_entered(body):
	if body != player: return
	
	player.cam_zoom = .75
	
	print("goop")
	
	player.autonomous = true
	
	var actionA = Action.new(player, "LerpMove", Vector2(player.position.x, 640), 200)
	var actionB = Action.new(player, "LerpMove", Vector2(960, 640), 200)
	var actionC = Action.new(player, "LerpMove", Vector2(960, 539), 200)
	
	var actions : Array[Action] = [actionA, actionB, actionC]
	for action in actions:
		add_child(action)
	
	cm = CutsceneManager.new(actions)
	add_child(cm)
	
	cm.series_action()
	await cm.actions_complete
