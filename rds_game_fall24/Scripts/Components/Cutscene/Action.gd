class_name Action
extends Node

var actor : Node2D
var type : String 

var mark : Vector2
var speed : float

signal action_completed(action)
@onready var action_finished = false # bool for parallel actions confirming that all actions are done asynchronously

var walk_t : float
var start_pos : Vector2

var anim_player : AnimationPlayer

# constructor call for a Walk Action (actor moves to mark at the given speed)
func _init(actor: Node2D, type: String, mark: Vector2, speed: float):
	self.actor = actor
	self.type = type
	
	if (actor.has_node("AnimationPlayer")):
		anim_player = actor.get_node("AnimationPlayer")
	
	# FOR MOVEMENT TYPES:
	self.mark = mark
	self.speed = speed

func _ready():
	self.set_process(false) # ensure that the action doesnt run until cue

func cue():
	if (type == "AStarMove"):
		actor.autonomous = true
	self.set_process(true) # begin performing the action
	
	walk_t = 0.
	start_pos = actor.position
	
	await action_completed
	action_finished = true
	self.set_process(false) # end the action

func skip_action():
	walk_t = 1.

func _process(delta):
	match type:
		"AStarMove":
			actor.target_pos = mark
			actor.speed = speed
			if (!actor.autonomous):
				actor.position = mark
				action_completed.emit()
				self.set_process(false)
		"LerpMove":
			var diff = mark - start_pos
			var unit = diff / diff.length()
			
			walk_t += delta * speed / (abs(diff.length()))
			actor.position = start_pos.lerp(mark, walk_t)
			
			var theta = atan2(diff.y, diff.x)
			set_directional_anim(theta, true)
			
			if (walk_t >= 1.):
				# actor.position = mark  # Snap to the exact target position
				set_directional_anim(theta, false)
				action_completed.emit()
				self.set_process(false)  # Stop further processing
		"SmoothMove":
			actor.position = actor.position.lerp(mark, delta * speed)
			
			if approximately_at(actor.position.x, mark.x, 1.0) and approximately_at(actor.position.y, mark.y, 1.0):
				actor.position = mark  # Snap to the exact target position
				action_completed.emit()
				self.set_process(false)  # Stop further processing

func set_directional_anim(theta, moving):
	if not anim_player:
		return
	
	theta = fmod(theta, TAU)
	if theta < 0.:
		theta += TAU
	
	var next_anim = ""
	if ((theta <= PI / 4) and (theta >= 0)) or ((theta >= 7 * PI / 4) and (theta <= 2 * PI)):
		next_anim = "walkRight" if moving else "idleRight"
	if (theta >= PI / 4) and (theta <= 3 * PI / 4):
		next_anim = "walkDown" if moving else "idleDown"
	if (theta >= 3 * PI / 4) and (theta <= 5 * PI / 4):
		next_anim = "walkLeft" if moving else "idleLeft"
	if (theta >= 5 * PI / 4) and (theta <= 7 * PI / 4):
		next_anim = "walkUp" if moving else "idleUp"
		# print(theta)
	
	if anim_player.current_animation != next_anim:
		if actor is CharacterController:
			anim_player.play(str(actor.anim_lib_name) + ("/" if actor.anim_lib_name != "" else "") + str(next_anim))
		else:
			anim_player.play(next_anim)
		# print("hello")
		# print(anim_player.get_queue())

func approximately_at(a: float, b: float, tolerance: float) -> bool:
	return abs(a - b) <= tolerance
