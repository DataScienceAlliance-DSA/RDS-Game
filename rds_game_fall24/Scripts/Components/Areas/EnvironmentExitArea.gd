extends Area2D

@onready var player_body = get_tree().get_nodes_in_group("Player")[0]
@onready var area_activated = false

@export var from_scene_name : String
@export var to_scene_name : String

@export var from_respawn_position : Vector2 # where the player should reappear when coming from this exit
@export var to_spawn_position : Vector2 # where the player should reappear when coming from this exit
# MAKE SURE THAT THE RESPAWN_POSITION IS NOT WITHIN THE AREA
@onready var first_frame_complete : bool = false # trigger for respawn pos, workaround for _ready() not handling body overlapping correctly
@onready var second_frame_complete : bool = false

func interact():
	return

func _ready():
	return

func _physics_process(delta):
	if (get_overlapping_bodies().has(player_body)) and !area_activated:
		player_body.autonomous = true
		area_activated = true
		PS.spawning_at = to_spawn_position
		UI.start_scene_change(true, true, "res://Scene Folder/Environment/" + to_scene_name + ".tscn")
