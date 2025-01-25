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
var speed : float = 3.

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
	var target_pos = Vector2(1600, -1680)
	
	if (!hopping):
		var path = map.getAStarPath(start_pos, target_pos)
		# print(path)
		if path.size() > 2:
			path.pop_front() # This removes the starting point from the path
			move_target = path.pop_front() # This gives us the point towards the enemy should move
			move_start = self.position
			hop_interpolation = 0.
			hopping = true
			# print("goob")
			# occupyAStarCell(move_target)
		else:
			# print(position)
			pass
	else:
		hop_interpolation += (delta * speed)
		moveTo(move_start, move_target, hop_interpolation)
	# print(hop_interpolation)
	super(delta)

func moveTo(start_pos : Vector2, target_pos : Vector2, t : float):
	if (t >= 1.):
		# freeAStarCell(target_pos)
		hopping = false
	self.position = start_pos.lerp(target_pos, t)
