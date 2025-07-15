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

var cue_wait_max : float
var cue_wait_timer : float
var active_cue : Dictionary
@onready var routine_index : int = 0

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
	## NAVIGATION PROCESS
	if !autonomous:
		autonomous = true
	else:
		super(delta)
	
	## CUE PROCESS
	if (active_cue):
		match(active_cue["type"]):
			"action":
				target_pos = active_cue["payload"]
				
				if (self.global_position.distance_to(target_pos) < 1.):
					active_cue = {}
			"blurb":
				var text = active_cue["payload"]
				
				if (cue_wait_timer >= cue_wait_max):
					cue_wait_timer += delta
					active_cue = {}
			"wait":
				if (cue_wait_timer >= cue_wait_max):
					cue_wait_timer += delta
					active_cue = {}
			"_":
				print("BAD ACTION PLAYED")
				active_cue = {}
	else:
		active_cue = get_cue(routine_index)

func get_cue(idx: int) -> Dictionary:
	if routine.is_empty():
		push_error("get_cue: routine is empty")
		return {}
	
	# Wrap the index (supports negative indices too)
	var wrapped := (idx % routine.size() + routine.size()) % routine.size()
	var cue = routine[wrapped]
	cue_wait_timer = 0.
	routine_index += 1
	
	match cue.get("type", ""):
		"action":
			var p = cue["position"]
			return { "type": "action", "payload": Vector2(p["x"], p["y"]) }
		"blurb":
			cue_wait_max = float(len(cue["text"]))
			return { "type": "blurb",  "payload": cue["text"] }
		"wait":
			cue_wait_max = float(cue["seconds"])
			return { "type": "wait",   "payload": float(cue["seconds"]) }
		_:
			push_error("get_cue: unknown cue type %s" % cue["type"])
			return {}
