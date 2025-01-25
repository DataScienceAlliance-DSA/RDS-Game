# CHARACTER_CONTROLLER
# handles character (NPC)'s state of autonomy
# handles character movement when autonomy is active
class_name CharacterController
extends CharacterBody2D
# - deeg

var autonomous : bool # dictates whether or not its own routines control itself

@onready var map : ConstructedTileMap = get_tree().get_nodes_in_group("Map")[0] as ConstructedTileMap
@onready var aStar : AStar2D = map.aStar as AStar2D

func _ready():
	autonomous = true
	print("Character controller")

func _process(float):
	if (!autonomous): return

func occupyAStarCell(vGlobalPosition:Vector2)->void:
	var vCell:=map.local_to_map(vGlobalPosition)
	var idx = map.getAStarCellIndex(vCell)
	if aStar.has_point(idx): aStar.set_point_disabled(idx, true)

func freeAStarCell(vGlobalPosition:Vector2)->void:
	var vCell:=map.local_to_map(vGlobalPosition)
	var idx = map.getAStarCellIndex(vCell)
	if aStar.has_point(idx): aStar.set_point_disabled(idx, false)
