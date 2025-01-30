# SICK_VILLAGER:
# NPC controller for the sick villagers in fairness minigame 1
class_name SickVillager
extends CharacterController
# - deeg

@onready var shape_sprite : Sprite2D = get_node("ShapeSprite")
@onready var area2d: Area2D = $Area2D


### Exists in CharacterController Parent class
#var move_target : Vector2
#var move_start : Vector2
#@onready var hopping : bool = false
#@onready var hop_interpolation : float = 0.

#@export var speed : float = 100. # 100 is default speed
#@export var target_pos : Vector2

func _ready():
	# set random shape for the sick villager
	var shape_index = randi() % 6
	area2d.set("shape_index", shape_index)
	
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
	super(delta)

func moveTo(start_pos : Vector2, target_pos : Vector2, t : float):
	target_pos *= 64.
	target_pos = Vector2(target_pos.x + 32., target_pos.y + 32.)
	t /= ((target_pos - start_pos).length());
	if (t >= 1.):
		hopping = false
	self.position = start_pos.lerp(target_pos, t)
