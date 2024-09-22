extends TileMapLayer
var movement_data

func _ready():
	## Reference variable to any particular movement cost of any particular tile
	movement_data = tile_set.movement_data

## Get the movement cost of any single cell on the map
## We pass in the grid, so that we don't take in the data from tiles that have been placed outside the play area
func get_movement_costs(grid: Grid):
	var movement_costs = []
	for y in range(grid.size.y):
		movement_costs.append([])
		for x in range(grid.size.x):
			## This requires that all tiles with a movement cost MUST be on layer 0 of the tilemap
			var tile = get_cell_source_id(Vector2i(x,y))
			var movement_cost = movement_data.get(tile)
			movement_costs[y].append(movement_cost)
	return movement_costs
