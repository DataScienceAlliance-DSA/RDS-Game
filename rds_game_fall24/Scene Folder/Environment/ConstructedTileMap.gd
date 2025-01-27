# CONSTRUCTED_TILEMAP:
# constructs AStar nodes around the entire map that maps out obstacles for NPCs
class_name ConstructedTileMap
extends TileMap
# - deeg

var aStar : AStar2D # AStar2D manager of all nodes

func _ready():
	# get and reserve size of scene space on aStar
	var size = self.get_used_rect().size
	aStar = AStar2D.new()
	aStar.reserve_space(size.x * size.y)
	
	# add points on all cells in tilemap to aStar
	for i in size.x:
		for j in size.y:
			if get_cell_source_id(0, Vector2(i,j))!=-1:
				var idx = getAStarCellIndex(Vector2(i,j))
				aStar.add_point(idx, Vector2(i,j))
	
	# fill and connect aStar's grid with all valid cells
	for i in size.x:
		for j in size.y:
			if get_cell_source_id(0, Vector2(i,j))!=-1:
				var idx = getAStarCellIndex(Vector2(i,j))
				for vNeighborCell in [Vector2(i,j-1),Vector2(i,j+1),Vector2(i-1,j),Vector2(i+1,j)]:
					if (vNeighborCell.x >= 0) and (vNeighborCell.x < size.x) and (vNeighborCell.y >= 0) and (vNeighborCell.y < size.y):
						var idxNeighbor=getAStarCellIndex(vNeighborCell)
						if aStar.has_point(idxNeighbor) and get_cell_source_id(0, vNeighborCell)!=-1:
							# print("DID I EVER EVEN HAPPEN")
							aStar.connect_points(idx, idxNeighbor, false)
	
	for i in size.x:
		for j in size.y:
			if get_cell_source_id(0, Vector2(i,j)) != -1:
				var idx = getAStarCellIndex(Vector2(i,j))
				# print("#" + str(idx) + ": " + str(aStar.get_point_connections(idx)))
	
	# DEBUG visualize the cells
	var astar_debugger = get_parent().get_node("DEBUG") as Node2D
	# print(astar_debugger.name)
	astar_debugger.visualize(aStar)

func getAStarPath(vStartPosition:Vector2,vTargetPosition:Vector2)->Array:
	var vCellStart = vStartPosition
	# print("HELP: " + str(vCellStart))
	var idxStart = getAStarCellIndex(local_to_map(to_local(vCellStart)))
	# print(idxStart)
	var vCellTarget = vTargetPosition
	var idxTarget = getAStarCellIndex(local_to_map(to_local(vCellTarget)))
	# Just a small check to see if both points are in the grid
	print(str(vStartPosition) + " start " + str(idxStart) + " " + str(aStar.has_point(idxStart)))
	print(str(vTargetPosition) + " target " + str(idxTarget) + " " + str(aStar.has_point(idxTarget)))
	if aStar.has_point(idxStart) and aStar.has_point(idxTarget):
		# print(Array(aStar.get_point_path(idxStart, idxTarget)))
		return Array(aStar.get_point_path(idxStart, idxTarget))
	return []

func getAStarCellIndex(vCell : Vector2):
	return int(vCell.y + vCell.x * self.get_used_rect().size.y)
