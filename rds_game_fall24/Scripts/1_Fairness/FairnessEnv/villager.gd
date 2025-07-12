# VILLAGER:
# Environmental NPCs in the fairness village
class_name Villager
extends CharacterController
# - deeg

@onready var villager_sprites = [
	$villager_sprites/GreenVillager,
	$villager_sprites/OrangeVillager,
	$villager_sprites/PeachVillager,
	$villager_sprites/BlueVillager
]

@export var routine_json : String
var routine : Array = []

var interactor
var interactions

func _ready():
	# randomly choose villager sprite
	for sprite in villager_sprites:
		sprite.hide()
	
	# Randomly select and show one
	var chosen_sprite = villager_sprites[randi() % villager_sprites.size()]
	chosen_sprite.show()
	anim_player = chosen_sprite.get_node("AnimationPlayer")
	anim_lib_name = anim_player.get_animation_list()[0].get_slice("/",0)
	print(anim_player.get_animation_list())
	
	## LOAD ROUTINE JSON DATA if any
	var data
	
	var file = FileAccess.open(routine_json, FileAccess.READ)
	if file: data = JSON.parse_string(file.get_as_text())
	if data: routine = data["routine"]
	
	super()

func _process(delta):
	if !autonomous:
		autonomous = true
	else:
		super(delta)

func get_cue(idx: int) -> Dictionary:
	if routine.is_empty():
		push_error("get_cue: routine is empty")
		return {}
	
	# Wrap the index (supports negative indices too)
	var wrapped := (idx % routine.size() + routine.size()) % routine.size()
	var cue = routine[wrapped]
	
	match cue.get("type", ""):
		"action":
			var p = cue["position"]
			return { "type": "action", "payload": Vector2(p["x"], p["y"]) }
		"blurb":
			return { "type": "blurb",  "payload": cue["text"] }
		"wait":
			return { "type": "wait",   "payload": float(cue["seconds"]) }
		_:
			push_error("get_cue: unknown cue type %s" % cue["type"])
			return {}
