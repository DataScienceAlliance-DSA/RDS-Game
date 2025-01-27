# SICK_VILLAGER:
# NPC controller for the sick villagers in fairness minigame 1
class_name SickVillager
extends CharacterController
# - deeg

@onready var shape_sprite : Sprite2D = get_node("ShapeSprite")
var move_target : Vector2
var move_start : Vector2
@onready var hopping : bool = false
@onready var hop_interpolation : float = 0.

@export var speed : float = 100. # 100 is default speed
@export var target_pos : Vector2

func _ready():
	# set random shape for the sick villager
	var shape_index = randi() % 6
	
	match(shape_index):
		0:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/circlePLACEHOLDER.PNG")
		1:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/crossPLACEHOLDER.PNG")
		2:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/diamondPLACEHOLDER.PNG")
		3:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/hexagonPLACEHOLDER.PNG")
		4:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/squarePLACEHOLDER.PNG")
		5:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/trianglePLACEHOLDER.PNG")
	# print(self.position)
	
	super()

func _process(delta):
	if (!autonomous): return
	
	# set the pattern
	var start_pos = self.position
	
	if (!hopping):
		var path = map.getAStarPath(start_pos, target_pos)
		# print(path)
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
			# print("goob")
		else:
			# print(position)
			pass
	else:
		hop_interpolation += (delta * speed)
		moveTo(move_start, move_target, hop_interpolation)
	# print(hop_interpolation)
	super(delta)

func moveTo(start_pos : Vector2, target_pos : Vector2, t : float):
	target_pos *= 64.
	target_pos = Vector2(target_pos.x + 32., target_pos.y + 32.)
	t /= ((target_pos - start_pos).length());
	if (t >= 1.):
		hopping = false
	self.position = start_pos.lerp(target_pos, t)
