## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const OBSTACLE_ATLAS_ID = 2

## Resource of type Grid.
@export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _walkable_cells := []
var _attackable_cells := []
var _movement_costs

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath
@onready var _map: TileMapLayer = $Map

const MAX_VALUE: int = 99999

func _ready() -> void:
	_movement_costs = _map.get_movement_costs(grid)
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return _units.has(cell)


## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return _dijkstra(unit.cell, unit.move_range, false)

## Return an array of cells a given unit can attack using dijkstra's and flood fill algorithm
func get_attackable_cells(unit: Unit) -> Array:
	var attackable_cells = []
	var real_walkable_cells = _dijkstra(unit.cell, unit.move_range, true)
	
	## iterate through every single cell and find their partners based on attack range
	for curr_cell in real_walkable_cells:
		for curr_range in range(1, unit.attack_range + 1):
			attackable_cells = attackable_cells + _flood_fill(curr_cell, unit.attack_range)
	
	return attackable_cells.filter(func(i): return i not in real_walkable_cells)

## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit


## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var full_array := []
	var wall_array := []
	var stack := [cell]
	while not stack.size() == 0:
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in full_array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		full_array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			
			## This detects the impassable objects we define in the TileSet based on the Atlas ID
			## If you don't want units to attack over walls and only around them comment out this line and put 'continue'
			if _map.get_cell_source_id(coordinates) == OBSTACLE_ATLAS_ID:
				wall_array.append(coordinates)
			
			#if is_occupied(coordinates):
			#	continue
			if coordinates in full_array:
				continue
			# Minor optimization: If this neighbor is already queued
			#	to be checked, we don't need to queue it again
			if coordinates in stack:
				continue
			
			stack.append(coordinates)
	
	## Filter out all the walls and return attackable cells
	return full_array.filter(func(i): return i not in wall_array)

## Generates a list of walkable cells based on unit movement value and tile movement cost
func _dijkstra(cell: Vector2, max_distance: int, attackable_check: bool) -> Array:
	var movable_cells = [cell] # append our base cell to the array
	var visited = [] # 2d array that keeps track of which cells we've already looked at while running the algorithm
	var distances = [] # shows distance to each cell, might be useful. can omit if you want to
	var previous = [] #2d array that shows you which cell you have to take to get there to get the shortest path. can omit if you want to
	## the previous array can be used to recontruct the path alogrithm found to the previous node you were at
	
	## iterate over width and height of the grid
	for y in range(grid.size.y):
		visited.append([])
		distances.append([])
		previous.append([])
		for x in range(grid.size.x):
			visited[y].append(false)
			distances[y].append(MAX_VALUE)
			previous[y].append(null)
	
	## Make new queue
	var queue = PriorityQueue.new()
	
	queue.push(cell, 0) #starting cell
	distances[cell.y][cell.x] = 0
	
	var tile_cost
	var distance_to_node
	var occupied_cells = []
	
	## While there is still a node in the queue, we'll keep looping
	while not queue.is_empty():
		var current = queue.pop() #take out the front node
		visited[current.value.y][current.value.x] = true #mark front node as visited
		
		for direction in  DIRECTIONS:
			var coordinates = current.value + direction #Go through all four neighbors of current node
			if grid.is_within_bounds(coordinates):
				if visited[coordinates.y][coordinates.x]:
					continue
				else:
					tile_cost = _movement_costs[coordinates.y][coordinates.x]
					
					distance_to_node = current.priority + tile_cost #calculate tile cost normally
					
					## Check to see if tile is occupied by opposite team or is waiting
					## the "or _units[coordinates].is_wait" is the line that you will use to calculate 
					## Actual attack range for display on hover/walk
					if is_occupied(coordinates):
						if _active_unit.is_enemy != _units[coordinates].is_enemy: #Remove this line if you want to make every unit impassable
							distance_to_node = current.priority + MAX_VALUE #Mark enemy tile as impassable
						## remove this if you want attack ranges to be seen past units that are waiting
						elif _units[coordinates].is_wait and attackable_check:
							occupied_cells.append(coordinates)
					
					visited[coordinates.y][coordinates.x] = true
					distances[coordinates.y][coordinates.x] = distance_to_node
				
				if distance_to_node <= max_distance: #check if node is actually reachable by our unit
					previous[coordinates.y][coordinates.x] = current.value #mark tile we used to get here
					movable_cells.append(coordinates) #attach new node we are looking at as reachable
					queue.push(coordinates, distance_to_node) #use distance as priority
	
	return movable_cells.filter(func(i): return i not in occupied_cells)

## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	# warning-ignore:return_value_discarded
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	_clear_active_unit()


## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return

	_active_unit = _units[cell]
	_active_unit.is_selected = true
	
	## Acquire the walkable and attackable cells
	_walkable_cells = get_walkable_cells(_active_unit)
	_attackable_cells = get_attackable_cells(_active_unit)
	
	## Draw out the walkable and attackable cells now
	_unit_overlay.draw_attackable_cells(_attackable_cells)
	_unit_overlay.draw_walkable_cells(_walkable_cells)
	
	_unit_path.initialize(_walkable_cells)


## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()


## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)


## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)
