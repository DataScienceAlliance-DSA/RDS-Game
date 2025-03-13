# SICK_VILLAGER:
# NPC controller for the sick villagers in fairness minigame 1
class_name SickVillager
extends CharacterController
# - deeg

@onready var circle_sprite = load("res://assets/Fairness_Village/Shapes/shape_2.PNG")
@onready var cross_sprite = load("res://assets/Fairness_Village/Shapes/shape_6.PNG")
@onready var diamond_sprite = load("res://assets/Fairness_Village/Shapes/shape_4.PNG")
@onready var hexagon_sprite = load("res://assets/Fairness_Village/Shapes/shape_5.PNG")
@onready var square_sprite = load("res://assets/Fairness_Village/Shapes/shape_3.PNG")
@onready var triangle_sprite = load("res://assets/Fairness_Village/Shapes/shape_1.PNG")

@onready var shape_sprite : Sprite2D = get_node("ShapeSprite")
@onready var area2d: Area2D = $Area2D
var shape_index

# for setting called-animation based on controller instructions
var animations

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

@onready var refusing_shape = false # plays indicator for 'shape already gotten' if true
var refusal_t
var post_refusal_position

@onready var villager_sprites = [
	$villager_sprites/GreenVillager,
	$villager_sprites/OrangeVillager,
	$villager_sprites/PeachVillager,
	$villager_sprites/BlueVillager
]

func _ready():
	# randomly choose villager sprite
	for sprite in villager_sprites:
		sprite.hide()
	
	# Randomly select and show one
	var chosen_sprite = villager_sprites[randi() % villager_sprites.size()]
	chosen_sprite.show()
	animations = chosen_sprite.get_node("AnimationPlayer")
	#chosen_sprite.play("idle")  # Play default animation
	
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
			shape_sprite.texture = circle_sprite
			if (orientation == 0):
				start = l
				target_pos_arr = [d,g,c,n]
			else:
				start = n
				target_pos_arr = [c,g,d,l]
		1:
			shape_sprite.texture = cross_sprite
			if (orientation == 0):
				start = l
				target_pos_arr = [z]
			else:
				start = z
				target_pos_arr = [l]
		2:
			shape_sprite.texture = diamond_sprite
			if (orientation == 0):
				start = m
				target_pos_arr = [d,g,c,m]
			else:
				start = m
				target_pos_arr = [c,g,d,m]
		3:
			shape_sprite.texture = hexagon_sprite
			if (orientation == 0):
				start = m
				target_pos_arr = [a,h,g,i,b,m]
			else:
				start = y
				target_pos_arr = [f,b,a,e,y]
		4:
			shape_sprite.texture = square_sprite
			if (orientation == 0):
				start = l
				target_pos_arr = [b,f,e,l]
			else:
				start = z
				target_pos_arr = [e,a,b,z]
		5:
			shape_sprite.texture = triangle_sprite
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
	if (refusing_shape):
		refusal_t += delta
		var shift = 12.*cos(pow(PI*(refusal_t+0.5),2.))*cos(PI*(refusal_t+0.5))
		self.position = post_refusal_position + Vector2(shift,0.)
		if (refusal_t >= 1.):
			refusing_shape = false
			self.position = post_refusal_position
		return
	
	if (!autonomous):
		if (target_pos_arr.size() != 0):
			target_pos = target_pos_arr.pop_front()
			autonomous = true
		else:
			villager_complete = true
	else:
		super(delta)

func moveTo(start_pos : Vector2, target_pos : Vector2, t : float):
	target_pos *= 64.
	target_pos = Vector2(target_pos.x + 32., target_pos.y + 32.)
	t /= ((target_pos - start_pos).length());
	if (t >= 1.):
		hopping = false
	self.position = start_pos.lerp(target_pos, t)

func refuse_shape():
	refusal_t = 0.
	post_refusal_position = self.position
	refusing_shape = true
	# SET ANIMATIONS TO FRONT IDLE HERE ONCE IMPORTED

# PAUSES ALL STATES OF CHARACTER (animation, movement, etc.)
func pause():
	animations.pause()
	super()
# RESUMES
func resume():
	animations.play()
	super()
