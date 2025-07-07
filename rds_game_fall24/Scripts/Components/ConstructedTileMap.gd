# CONSTRUCTED_TILEMAP:
# constructs AStar nodes around the entire map that maps out obstacles for NPCs
class_name ConstructedTileMap
extends TileMap
# - deeg

var aStar : AStar2D # AStar2D manager of all nodes
var rect : Rect2i

func _ready():
	# get and reserve size of scene space on aStar
	rect = self.get_used_rect()
	aStar = AStar2D.new()
	aStar.reserve_space(rect.size.x * rect.size.y)
	
	# add points on all cells in tilemap to aStar
	for i in rect.size.x:
		for j in rect.size.y:
			var cell = rect.position + Vector2i(i, j)
			if get_cell_source_id(0, cell) != -1:
				var idx = getAStarCellIndex(cell)
				aStar.add_point(idx, cell)
	
	# fill and connect aStar's grid with all valid cells
	for i in rect.size.x:
		for j in rect.size.y:
			var cell = rect.position + Vector2i(i, j)
			if get_cell_source_id(0, cell)!=-1:
				var idx = getAStarCellIndex(cell)
				for offset in [Vector2i(0,-1),Vector2i(0,1),Vector2i(-1,0),Vector2i(1,0)]:
					var neighbor = cell + offset
					if get_cell_source_id(0, neighbor) != -1:
						var neighbor_idx = getAStarCellIndex(neighbor)
						if aStar.has_point(neighbor_idx):
							aStar.connect_points(idx, neighbor_idx, false)
	
	# DEBUG visualize the cells
	# var astar_debugger = get_parent().get_node("DEBUG") as Node2D
	# print(astar_debugger.name)
	# astar_debugger.visualize(aStar)

func getAStarPath(vStartPosition:Vector2,vTargetPosition:Vector2)->Array:
	var vCellStart = vStartPosition
	# print("HELP: " + str(vCellStart))
	var idxStart = getAStarCellIndex(local_to_map(to_local(vCellStart)))
	# print(idxStart)
	var vCellTarget = vTargetPosition
	var idxTarget = getAStarCellIndex(local_to_map(to_local(vCellTarget)))
	# Just a small check to see if both points are in the grid
	if aStar.has_point(idxStart) and aStar.has_point(idxTarget):
		# print(Array(aStar.get_point_path(idxStart, idxTarget)))
		return Array(aStar.get_point_path(idxStart, idxTarget))
	return []

func getAStarCellIndex(vCell : Vector2i):
	var local = vCell - rect.position
	return int(local.y + local.x * rect.size.y)
