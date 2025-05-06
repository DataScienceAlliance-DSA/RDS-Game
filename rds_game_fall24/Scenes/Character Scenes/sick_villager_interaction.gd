# SICK_VILLAGER:
# NPC controller for the sick villagers in fairness minigame 1
extends CharacterBody2D
# - deeg

@onready var shape_sprite : Sprite2D = get_node("ShapeSprite")

### Exists in CharacterController Parent class
#var move_target : Vector2
#var move_start : Vector2
#@onready var hopping : bool = false
#@onready var hop_interpolation : float = 0.

#@export var speed : float = 100. # 100 is default speed
#@export var target_pos : Vector2

# Interaction Signal and Variable
signal interacted

var can_interact := false # Tracks interaction range

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

func _on_Area2D_body_entered(body):
	if body.name == "main_character": 
		can_interact = true
		
func _on_Area2D_body_exited(body):
	if body.name == "main_character":
		can_interact = false

func is_in_interaction_range() -> bool:
	return can_interact
	
func _input(event):
	if event.is_action_pressed("interact"):
		if is_in_interaction_range():
			_on_interacted()

func _on_interacted():
	interacted.emit()
