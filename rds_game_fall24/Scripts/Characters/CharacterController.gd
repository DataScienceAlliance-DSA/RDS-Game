# CHARACTER_CONTROLLER
# handles character (NPC)'s state of autonomy
# handles character movement when autonomy is active
class_name CharacterController
extends CharacterBody2D
# - deeg

@export var start_autonomous : bool # dictates whether autonomous from start of scene
var autonomous : bool # dictates whether or not its own routines control itself
@export var speed : float = 100. # 100 is default speed
@export var target_pos : Vector2

@onready var map : ConstructedTileMap = get_tree().get_nodes_in_group("Map")[0] as ConstructedTileMap
@onready var aStar : AStar2D = map.aStar as AStar2D

@onready var hopping : bool = false
var move_target : Vector2
var move_start : Vector2
@onready var hop_interpolation : float = 0.

var anim_player
@export var anim_lib_name : String ## IMPORTANT: set name of character's animation_framework here, or else animations in cutscenes/autonav will not work

func _ready():
	autonomous = start_autonomous

func _process(delta):
	# set the pattern
	var start_pos = self.position
	
	if (!hopping and autonomous):
		var path = map.getAStarPath(start_pos, target_pos)
		
		if path.size() > 2:
			path.pop_front() # This removes the starting point from the path
			move_target = path.pop_front() # This gives us the point towards the enemy should move
			
			# move_target.x=16*int(move_target.x/16)+8; move_target.y=16*int(move_target.y/16)+8
			# Here is the important stuff!
			self.freeAStarCell(self.position)
			self.occupyAStarCell(move_target)
			
			move_start = self.position
			hop_interpolation = 0.
			hopping = true
		elif (self.name != "Player"):
			autonomous = false
			pass
	else:
		hop_interpolation += (delta * speed)
		
		moveTo(move_start, move_target, hop_interpolation)

func set_autonomous(autonomous):
	self.autonomous = autonomous

func moveTo(start_pos : Vector2, target_pos : Vector2, t : float):
	target_pos *= 64.
	target_pos = Vector2(target_pos.x + 32., target_pos.y + 32.)
	
	t /= ((target_pos - start_pos).length());
	if (t >= 1.):
		hopping = false
	
	var diff = target_pos - start_pos
	var theta = atan2(diff.y, diff.x)
	
	set_directional_anim(theta, true)
	
	self.position = start_pos.lerp(target_pos, t)

func occupyAStarCell(vGlobalPosition:Vector2)->void:
	var vCell:=map.local_to_map(vGlobalPosition)
	var idx = map.getAStarCellIndex(vCell)
	if aStar.has_point(idx): aStar.set_point_disabled(idx, true)

func freeAStarCell(vGlobalPosition:Vector2)->void:
	var vCell:=map.local_to_map(vGlobalPosition)
	var idx = map.getAStarCellIndex(vCell)
	if aStar.has_point(idx): aStar.set_point_disabled(idx, false)

func set_directional_anim(theta, moving):
	if not anim_player:
		return
	
	theta = fmod(theta, TAU)
	if theta < 0.:
		theta += TAU
	
	anim_player.speed_scale = speed / 100.
	
	var next_anim = str(anim_lib_name) + "/"
	if ((theta <= PI / 4) and (theta >= 0)) or ((theta >= 7 * PI / 4) and (theta <= 2 * PI)):
		next_anim += "walkRight" if moving else "idleRight"
	if (theta >= PI / 4) and (theta <= 3 * PI / 4):
		next_anim += "walkDown" if moving else "idleDown"
	if (theta >= 3 * PI / 4) and (theta <= 5 * PI / 4):
		next_anim += "walkLeft" if moving else "idleLeft"
	if (theta >= 5 * PI / 4) and (theta <= 7 * PI / 4):
		next_anim += "walkUp" if moving else "idleUp"
	
	if anim_player.current_animation != next_anim:
		anim_player.play(next_anim)

# PAUSES ALL STATES OF CHARACTER (animation, movement, etc.)
func pause():
	self.set_process(false)
# RESUMES
func resume():
	self.set_process(true)
