extends Node2D

signal packages_updated(count: int)

@onready var whirlpools = get_tree().get_nodes_in_group("whirlpools")
@onready var riptides = get_tree().get_nodes_in_group("riptides")
@onready var player = $"Main Character"
@onready var crystal = get_tree().get_nodes_in_group("Crystal")[0]
@onready var game_ui = $UITransparencyMinigame2

@export var spin_speed: float = 0.7
@export var scale_speed: float = 1.0
@export var pull_speed: float = 200.0
@export var riptide_speed: float = 750.0

@export var total_packages: int = 5
var packages_remaining: int

var checkpoint_position: Vector2
var whirlpool_max_scales := {}

var current_delivery_island: Node2D = null

var group_to_direction := {
	"riptide_right": Vector2.RIGHT,
	"riptide_left": Vector2.LEFT,
	"riptide_up": Vector2.UP,
	"riptide_down": Vector2.DOWN,
}

var scale_time := 0.0
var pulling_whirlpool: Area2D = null
var total_spin := 0.0

var active_riptide: Area2D = null
var is_in_riptide := false
var riptide_path: Array[Vector2] = []
var riptide_path_index: int = 0

var cm : CutsceneManager # cutscene manager for this 

func _ready():
	var actions : Array[Action] = []
	cm = CutsceneManager.new(actions)
	add_child(cm)
	
	UI.set_tooltip("res://Assets/UI/tooltips/Transparency Mini Game_2.png")
	UI.start_scene_change(false, false, "")
	
	packages_remaining = total_packages
	emit_signal("packages_updated", packages_remaining)
	
	checkpoint_position = player.global_position
	
	for wp in whirlpools:
		wp.connect("body_entered", Callable(self, "_on_whirlpool_body_entered").bind(wp))
		whirlpool_max_scales[wp] = wp.scale  # Save the editor set scale!
	
	for rt in riptides:
		rt.connect("body_entered", Callable(self, "_on_riptide_body_entered").bind(rt))

func _process(delta):
	scale_time += delta
	for wp in whirlpools:
		wp.rotation += spin_speed * delta
		
		var max_scale = whirlpool_max_scales[wp]
		var oscillation = (sin(scale_time * scale_speed) + 1) / 2.0
		var min_scale_factor = 0.8  # Minimum breathing size (adjust if you want)
		var current_scale = lerp(min_scale_factor, 1.0, oscillation)
		
		wp.scale = max_scale * current_scale

	if pulling_whirlpool:
		var center = pulling_whirlpool.global_position
		var direction = (center - player.global_position).normalized()
		player.global_position += direction * pull_speed * delta

		if player.global_position.distance_to(center) < 20:
			player.global_position = checkpoint_position + Vector2(0, -16)  # small lift
			player.resume()
			pulling_whirlpool = null

	if is_in_riptide and riptide_path_index < riptide_path.size():
		var target = riptide_path[riptide_path_index]
		var direction = player.global_position.direction_to(target)
		player.global_position += direction * riptide_speed * delta

		if player.global_position.distance_to(target) < 5:
			player.global_position = target
			riptide_path_index += 1

			if riptide_path_index >= riptide_path.size():
				player.resume()
				is_in_riptide = false
				active_riptide = null
				riptide_path.clear()

func _on_whirlpool_body_entered(body, wp):
	if body == player and pulling_whirlpool == null:
		player.pause()
		player.hopping = false
		pulling_whirlpool = wp
		total_spin = 0.0

func _on_riptide_body_entered(body, rt):
	if body != player or is_in_riptide:
		return
	player.pause()
	player.hopping = false
	active_riptide = rt
	is_in_riptide = true
	riptide_path = rt.get_endpoint_chain()
	riptide_path_index = 0

func _unhandled_input(event):
	if event.is_action_pressed("interaction") and current_delivery_island and packages_remaining > 0:
		deliver_package(current_delivery_island)

func deliver_package(island: Node2D):
	print("Deliver package called FROM:", self.name)
	packages_remaining -= 1
	emit_signal("packages_updated", packages_remaining)
	print("Signal emitted with packages_remaining:", packages_remaining)
	
	checkpoint_position = player.global_position

func end_game():
	set_process(false)
	player.autonomous = true
	
	crystal.global_position = player.global_position + Vector2(141,-64)
	
	crystal.get_node("crystal").texture = load("res://Assets/1_Fairness/FairnessEnv/transparency_crystal_animation.png")
	var crystal_rises = UniqueAction.new(crystal, Callable(crystal, "levitate"))
	var actions : Array[Action] = [crystal_rises]
	for action in actions:
		add_child(action)
	cm.set_actions(actions)
	cm.series_action()
	await cm.actions_complete
	
	UI.start_scene_change(true, true, "res://Scenes/3_Privacy/PrivacyMinigame1/Information_Game/information_game.tscn")
