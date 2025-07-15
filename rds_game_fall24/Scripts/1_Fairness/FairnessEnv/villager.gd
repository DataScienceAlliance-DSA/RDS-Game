# VILLAGER:
# Environmental NPCs in the fairness village
class_name Villager
extends CharacterController
# - deeg

@onready var player = get_tree().get_nodes_in_group("Player")[0]

@onready var villager_sprites = [
	$villager_sprites/GreenVillager,
	$villager_sprites/OrangeVillager,
	$villager_sprites/PeachVillager,
	$villager_sprites/BlueVillager,
	$villager_sprites/Player
]

@export var routine_enabled : bool
@export var routine_interruptable : bool # routine may be interrupted by player interacting
@export var routine_json : String
@export var sprite_index : int
var routine : Array = []

var interactor
var interactions

var cue_wait_max : float
var cue_wait_timer : float
var active_cue : Dictionary
@onready var routine_index : int = 0

# ───────────────────────────────────────────────────────────────
#  GLOBALS (put near the other @onready vars)
# ───────────────────────────────────────────────────────────────
@onready var text_bubble := $TextPanel/TextBubble          # parent container (can be a Control or Node2D)
@onready var text_label  := $TextPanel/TextLabel
var blurb_text      : String = ""                # full line we’re printing
var blurb_char_idx  : int    = 0                 # current character
var blurb_speed     : float  = 0.045             # seconds per character ## 3x slower than base text speed ie in dialogue/monologues111111111111
var blurb_timer     : float  = 0.0               # accumulates real‑time
# ───────────────────────────────────────────────────────────────

func _ready():
	# randomly choose villager sprite
	for sprite in villager_sprites:
		sprite.hide()
	
	# Randomly select and show one
	var chosen_sprite = villager_sprites[sprite_index]
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
	if (interactor and routine_interruptable):
		if text_bubble.scale.x > 0: close_blurb()
		set_directional_anim(self.global_position.angle_to_point(player.global_position), false)
		return
	
	## NAVIGATION PROCESS
	if !autonomous:
		autonomous = true
	else:
		super(delta)
	
	## CUE PROCESS
	if (!routine_json) or (!routine_enabled): 
		return
	
	if (!active_cue.is_empty()):
		if active_cue["type"] != "blurb" and text_bubble.scale.x == 1: close_blurb()
		match(active_cue["type"]):
			"action":
				if (self.global_position.distance_to(target_pos) < 128.):
					active_cue = {}
			"blurb":
				if (cue_wait_timer < cue_wait_max): 
					cue_wait_timer += delta
					process_blurb()
				else: 
					active_cue = {}
			"wait":
				if (cue_wait_timer < cue_wait_max): cue_wait_timer += delta
				else: active_cue = {}
			"_":
				active_cue = {}
	else:
		active_cue = get_cue(routine_index)

func close_blurb():
	if !text_bubble.visible: return
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)                 
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(text_bubble, "scale:x", 0.0, 0.5)
	tween.parallel().tween_property(text_label, "scale:x", 0.0, 0.5)
	tween.parallel().tween_property(text_bubble, "position:x", 500.0, 0.5)

func process_blurb() -> void:
	# Called each frame while the cue is active
	if blurb_char_idx >= blurb_text.length():
		return                                         # done printing
	
	# advance timer
	blurb_timer += get_process_delta_time()
	
	# spit out the next character when enough time passed
	if blurb_timer >= blurb_speed:
		blurb_timer = 0.0
		blurb_char_idx += 1
		
		# ────────────────────────────────────────────────
		#  If the newly‑revealed char is “[”, skip ahead
		#  until the matching “]” so BBCode tags appear
		#  all at once instead of letter‑by‑letter.
		# ────────────────────────────────────────────────
		if blurb_text[blurb_char_idx - 1] == "[":
			while blurb_char_idx < blurb_text.length() \
					and blurb_text[blurb_char_idx] != "]":
				blurb_char_idx += 1          # skip tag body
			if blurb_char_idx < blurb_text.length():
				blurb_char_idx += 1          # include the “]”
		
		# now update text with new BBcode character
		text_label.text = "[center]" + blurb_text.substr(0, blurb_char_idx)
		
		# update size + position
		text_bubble.scale.x = 1.
		text_label.scale.x = 1.
		text_bubble.size.x = text_label.get_content_width() + 32.
		text_bubble.position.x = 500. - text_bubble.size.x / 2.
		text_label.size = text_bubble.size
		text_label.pivot_offset = text_label.size / 2.
		text_label.position.x = text_bubble.position.x

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
			target_pos = Vector2(p["x"], p["y"])
			return { "type": "action", "payload": target_pos }
		"blurb":
			cue_wait_max = cue["seconds"]
			blurb_text     = cue["text"]
			blurb_char_idx = 0
			blurb_timer    = 0.0
			text_label.text = ""
			# resetting text label, particularly for consecutive blurbs
			text_bubble.size.x = text_label.get_content_width() + 32.
			text_bubble.position.x = 500. - text_bubble.size.x / 2.
			text_label.size = text_bubble.size
			text_label.pivot_offset = text_label.size / 2.
			text_label.position.x = text_bubble.position.x
			text_bubble.visible = true
			return { "type": "blurb",  "payload": cue["text"] }
		"wait":
			cue_wait_max = float(cue["seconds"])
			return { "type": "wait",   "payload": float(cue["seconds"]) }
		_:
			push_error("get_cue: unknown cue type %s" % cue["type"])
			return {}
