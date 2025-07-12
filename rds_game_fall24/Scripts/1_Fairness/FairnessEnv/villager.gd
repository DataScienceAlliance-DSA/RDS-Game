# VILLAGER:
# Environmental NPCs in the fairness village
class_name Villager
extends CharacterController
# - deeg

@onready var villager_sprites = [
	$villager_sprites/GreenVillager,
	$villager_sprites/OrangeVillager,
	$villager_sprites/PeachVillager,
	$villager_sprites/BlueVillager
]

@export var routine_walking : bool
@export var routine_pos : Vector2

func _ready():
	# randomly choose villager sprite
	for sprite in villager_sprites:
		sprite.hide()
	
	# Randomly select and show one
	var chosen_sprite = villager_sprites[randi() % villager_sprites.size()]
	chosen_sprite.show()
	anim_player = chosen_sprite.get_node("AnimationPlayer")
	anim_lib_name = anim_player.get_animation_list()[0].get_slice("/",0)
	print(anim_player.get_animation_list())
	
	super()

func _process(delta):
	if !autonomous:
		autonomous = true
		if routine_walking:
			target_pos = routine_pos
	else:
		super(delta)
