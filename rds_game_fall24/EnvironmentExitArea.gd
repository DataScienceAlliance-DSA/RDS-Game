extends Area2D

@onready var player_body = get_tree().get_nodes_in_group("Player")[0]
@onready var area_activated = false

@export var from_scene_name : String
@export var to_scene_name : String

@export var respawn_position : Vector2 # where the player should reappear when coming from this exit
# MAKE SURE THAT THE RESPAWN_POSITION IS NOT WITHIN THE AREA
@onready var first_frame_complete : bool = false # trigger for respawn pos, workaround for _ready() not handling body overlapping correctly
@onready var second_frame_complete : bool = false

func interact():
	return

func _ready():
	return

func _physics_process(delta):
	if (get_overlapping_bodies().has(player_body)):
		player_body.position = respawn_position
	
	if (get_overlapping_bodies().has(player_body)) and !area_activated:
		area_activated = true
		
		var scene_data = PackedScene.new()
		scene_data.pack(get_tree().get_current_scene())
		ResourceSaver.save(scene_data, "user://Saves/" + from_scene_name + ".tscn")
		
		if !FileAccess.file_exists("user://Saves/" + to_scene_name + ".tscn"):
			UI.start_scene_change(true, true, "res://Scene Folder/Environment/" + to_scene_name + ".tscn")
		else:
			UI.start_scene_change(true, true, "user://Saves/" + to_scene_name + ".tscn")
