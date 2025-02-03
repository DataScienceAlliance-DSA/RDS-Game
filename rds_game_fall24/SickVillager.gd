# SICK_VILLAGER:
# NPC controller for the sick villagers in fairness minigame 1
class_name SickVillager
extends CharacterController
# - deeg

@onready var shape_sprite : Sprite2D = get_node("ShapeSprite")
@onready var area2d: Area2D = $Area2D
var shape_index


### Exists in CharacterController Parent class
#var move_target : Vector2
#var move_start : Vector2
#@onready var hopping : bool = false
#@onready var hop_interpolation : float = 0.

#@export var speed : float = 100. # 100 is default speed
#@export var target_pos : Vector2

var start # total start position of a villager's journey
var target_pos_arr # array of all points a villager must walk to
@onready var villager_complete : bool = false # when true, gets freed in minigame script

func _ready():
	# set random shape for the sick villager
	shape_index = randi() % 6
	var orientation = randi() % 2
	area2d.set("shape_index", shape_index)
	
	var a = Vector2(256+512*randf(), 256+256*randf())
	var b = Vector2(1280+576*randf(), 256+256*randf())
	var c = Vector2(256+512*randf(), 512+256*randf())
	var d = Vector2(1280+576*randf(), 512+256*randf())
	var e = Vector2(256+512*randf(), 768+348*randf())
	var f = Vector2(1280+576*randf(), 768+348*randf())
	var g = Vector2(832+448*randf(), 864+252*randf())
	var h = Vector2(256+512*randf(), 512+604*randf())
	var i = Vector2(576*randf()+1280, 604*randf()+512)
	
	var l = Vector2(64,64)
	var m = Vector2(1024,64)
	var n = Vector2(2048,64)
	var x = Vector2(64,1280)
	var y = Vector2(1024,1280)
	var z = Vector2(2048,1280)
	
	
	match(shape_index):
		0:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/circlePLACEHOLDER.PNG")
			if (orientation == 0):
				start = l
				target_pos_arr = [d,g,c,n]
			else:
				start = n
				target_pos_arr = [c,g,d,l]
		1:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/crossPLACEHOLDER.PNG")
			if (orientation == 0):
				start = l
				target_pos_arr = [z]
			else:
				start = z
				target_pos_arr = [l]
		2:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/diamondPLACEHOLDER.PNG")
			if (orientation == 0):
				start = m
				target_pos_arr = [d,g,c,m]
			else:
				start = m
				target_pos_arr = [c,g,d,m]
		3:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/hexagonPLACEHOLDER.PNG")
			if (orientation == 0):
				start = m
				target_pos_arr = [a,h,g,i,b,m]
			else:
				start = y
				target_pos_arr = [f,b,a,e,y]
		4:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/squarePLACEHOLDER.PNG")
			if (orientation == 0):
				start = l
				target_pos_arr = [b,f,e,l]
			else:
				start = z
				target_pos_arr = [e,a,b,z]
		5:
			shape_sprite.texture = load("res://assets/Fairness_Village/Shapes/trianglePLACEHOLDER.PNG")
			if (orientation == 0):
				start = x
				target_pos_arr = [b,z]
			else:
				start = z
				target_pos_arr = [a,x]
	
	self.position = start
	self.speed = randfn(125,50)
	
	super()

func _process(delta):
	if (!autonomous):
		if (target_pos_arr.size() != 0):
			target_pos = target_pos_arr.pop_front()
			autonomous = true
		else:
			villager_complete = true
	super(delta)

func moveTo(start_pos : Vector2, target_pos : Vector2, t : float):
	target_pos *= 64.
	target_pos = Vector2(target_pos.x + 32., target_pos.y + 32.)
	t /= ((target_pos - start_pos).length());
	if (t >= 1.):
		hopping = false
	self.position = start_pos.lerp(target_pos, t)
