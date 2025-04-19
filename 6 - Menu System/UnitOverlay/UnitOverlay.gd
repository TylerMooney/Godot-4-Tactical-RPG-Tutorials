## Draws a selected unit's walkable tiles.
class_name UnitOverlay
extends TileMapLayer

## NOTE:
## set_cell(x,y,z,i): z indicates the ID number in unit_overlay_tileset for which tile to draw in the overlay
## to edit this ID or to add more cells, double click the unit_overlay_tileset.tres file in the explorer
## then select the tiles added to the tileset that you would like to edit

## Fills the tilemap with the cells, giving a visual representation of the cells a unit can walk.
func draw_walkable_cells(cells: Array) -> void:
	#clear()
	for cell in cells:
		set_cell(cell, 0, Vector2i(0,0))

## Fills the tilemap with the cells, giving a visual representation of the cells a unit can attack
func draw_attackable_cells(cells: Array) -> void:
	for cell in cells:
		set_cell(cell, 1, Vector2i(0,0))
