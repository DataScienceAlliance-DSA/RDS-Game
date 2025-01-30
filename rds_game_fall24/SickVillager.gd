# SICK_VILLAGER:
# NPC controller for the sick villagers in fairness minigame 1
class_name SickVillager
extends CharacterController
# - deeg

@onready var shape_sprite : Sprite2D = get_node("ShapeSprite")
@onready var interaction_area : Area2D = get_node("Area2D") # References Area2D node within the sick villager scene
@onready var monologue_ui: MarginContainer = UI.get_node("Monologue")


### Exists in CharacterController Parent class
#var move_target : Vector2
#var move_start : Vector2
#@onready var hopping : bool = false
#@onready var hop_interpolation : float = 0.

#@export var speed : float = 100. # 100 is default speed
#@export var target_pos : Vector2

# Interaction Signal
signal interacted_with(character)

# Interaction tracking variables
var interactor = null
var interactions = 0

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
	
	# Debugging for when something enters the area
	interaction_area.area_entered.connect(_on_area_entered)
	
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

func _on_area_entered(area):
	if area.get_parent() == get_tree().get_root():
		interact(area)
	print("Player entered interaction area!")
	
## INTERACT METHOD, called when player interacts with this area
func interact(interactor_object):
	interactor = interactor_object # set interactor source
	self.set_process(true) # enable area interaction screen
	print("Successful Interaction")
	self.set_process(false)
	#interactions = interactions + 1	# increment interactions made with this area
	#match interactions:
		#1:
			#monologue_ui.open_3choice_dialogue("res://Scripts/Monologues/Cauldron/OrbHypothesis.json", self)
		#_:
			#monologue_ui.open_3choice_dialogue("res://Scripts/Monologues/Cauldron/CauldronBlurb.json", self)
