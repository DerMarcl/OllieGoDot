extends TileMap
class_name TileMapPiratePathFind

@export var show_debug_graph: bool = true
@export var jump_distance: int = 5
@export var jump_height: int = 4

const COLLISION_LAYER := 0
const CELL_IS_EMPTY := -1
const MAX_TILE_FALL_SCAN_DEPTH := 500

var _astar := AStar2D.new()
var _used_tiles: Array[Vector2i] = []
var _graph_point := preload("res://Scenen/GraphPoint.tscn")
var _point_info_list: Array = []
var _debug_drawer: Node = null

func _ready():
	_debug_drawer = get_node_or_null("../DebugDrawer")
	if _debug_drawer == null:
		print("⚠️ DebugDrawer not found!")
	
	_used_tiles = get_used_cells(COLLISION_LAYER)
	build_graph()
	

func build_graph():
	add_graph_points()
	if not show_debug_graph:
		connect_points()


func get_point_info_at_position(position: Vector2) -> PointInfo:
	var info = PointInfo.new()
	info.point_id = -10000
	info.position = position
	info.is_position_point = true
	
	var tile = local_to_map(position)

	# Check if there is ground below the tile
	if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(0, 1)) != CELL_IS_EMPTY:
		
		# Left wall: tile to the left exists
		if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(-1, 0)) != CELL_IS_EMPTY:
			info.is_left_wall = true
		
		# Right wall: tile to the right exists
		if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(1, 0)) != CELL_IS_EMPTY:
			info.is_right_wall = true

		# Left edge: diagonal tile down-left exists
		if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(-1, 1)) != CELL_IS_EMPTY:
			info.is_left_edge = true

		# Right edge: diagonal tile down-right exists
		if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(1, 1)) != CELL_IS_EMPTY:
			info.is_right_edge = true
	
	return info
	
func reverse_path_stack(path_stack: Array) -> Array:
	var reversed := []
	while not path_stack.is_empty():
		reversed.append(path_stack.pop_back())
	return reversed

func get_platform_2d_path(start_pos: Vector2, end_pos: Vector2) -> Array:
	var raw_stack = internal_platform_2d_path(start_pos, end_pos)
	var result: Array = []

	for i in raw_stack.size():
		var point = raw_stack[i]
		var position = point.position
		if i != 0:
			position *= 3

		var dict := {
			"position": position,
			"is_left_edge": point.is_left_edge,
			"is_right_edge": point.is_right_edge,
			"is_fall_tile": point.is_fall_tile,
			"is_right_wall": point.is_right_wall,
			"is_left_wall": point.is_left_wall
		}
		result.append(dict)
	#debug_print_astar_points()
	return result

func internal_platform_2d_path(start_pos: Vector2, end_pos: Vector2) -> Array:
	var path_stack: Array = []
	var id_path = _astar.get_id_path(_astar.get_closest_point(start_pos/3), _astar.get_closest_point(end_pos/3))

	if id_path.is_empty():
		return path_stack

	var start_point = get_point_info_at_position(start_pos)
	var end_point = get_point_info_at_position(end_pos)
	var num_points = id_path.size()

	for i in range(num_points):
		var curr_point = get_info_point_by_id(id_path[i])

		if num_points == 1:
			continue

		if i == 0 and num_points >= 2:
			var second = get_info_point_by_id(id_path[i + 1])
			if start_point.position.distance_to(second.position) < curr_point.position.distance_to(second.position):
				path_stack.append(start_point)
				continue

		elif i == num_points - 1 and num_points >= 2:
			var penultimate = get_info_point_by_id(id_path[i - 1])
			if end_point.position.distance_to(penultimate.position) < curr_point.position.distance_to(penultimate.position):
				continue
			else:
				path_stack.append(curr_point)
				break

		path_stack.append(curr_point)

	path_stack.append(end_point)
	path_stack.reverse()
	
	return path_stack

func get_info_point_by_id(point_id: int) -> PointInfo:
	for point_info in _point_info_list:
		if point_info.point_id == point_id:
			return point_info
	return null


func draw_debug_line(from: Vector2, to: Vector2, color: Color):
	if not show_debug_graph or _debug_drawer == null:
		return

	_debug_drawer.call("add_line", from, to, color)

	# Optional immediate draw (Node2D draw call — used only in _draw() usually)
	if show_debug_graph and self.has_method("draw_line"):
		draw_line(from, to, color, 2.0)

func add_graph_points():
	for tile in _used_tiles:
		add_left_edge_point(tile)
		add_right_edge_point(tile)
		add_left_wall_point(tile)
		add_right_wall_point(tile)
		add_fall_point(tile)

func tile_already_exists_in_graph(tile: Vector2i) -> int:
	var local_pos = get_global_tile_center(tile)

	if _astar.get_point_count() > 0:
		var point_id = _astar.get_closest_point(local_pos)

		if _astar.get_point_position(point_id) == local_pos:
			return point_id  # The tile already exists in the graph
	return -1  # Tile not found in graph

func add_visual_point(tile: Vector2i, color: Color = Color.WHITE, scale: float = 1.0) -> void:
	if not show_debug_graph:
		return

	var visual_point := _graph_point.instantiate()
	
	if visual_point is Sprite2D:
		visual_point.modulate = color
		if scale != 1.0 and scale > 0.1:
			visual_point.scale = Vector2(scale, scale)
		visual_point.position = get_global_tile_center(tile)
		add_child(visual_point)

func get_point_info(tile: Vector2i) -> PointInfo:
	var center := get_global_tile_center(tile)
	for point_info in _point_info_list:
		if point_info.position == center:
			return point_info
	return null

func _draw():
	if show_debug_graph:
		connect_points()

func connect_points():
	for p1 in _point_info_list:
		connect_horizontal_points(p1)
		connect_jump_points(p1)
		connect_fall_point(p1)

func connect_fall_point(p1: PointInfo) -> void:
	if p1.is_left_edge or p1.is_right_edge:
		var tile_pos = local_to_map(p1.position)
		tile_pos.y += 1  # account for graph point being one tile above

		var fall_point = find_fall_point(tile_pos)
		if fall_point != null:
			var p2 = get_point_info(fall_point)
			if p2 == null:
				return

			var p1_map = local_to_map(p1.position)
			var p2_map = local_to_map(p2.position)

			if p1_map.distance_to(p2_map) <= jump_height:
				_astar.connect_points(p1.point_id, p2.point_id)
				draw_debug_line(p1.position, p2.position, Color.DARK_RED)
			else:
				_astar.connect_points(p1.point_id, p2.point_id, false)
				draw_debug_line(p1.position, p2.position, Color.YELLOW)

func connect_jump_points(p1: PointInfo) -> void:
	for p2 in _point_info_list:
		connect_horizontal_platform_jumps(p1, p2)
		connect_diagonal_jump_right_edge_to_left_edge(p1, p2)
		connect_diagonal_jump_left_edge_to_right_edge(p1, p2)

func connect_diagonal_jump_right_edge_to_left_edge(p1: PointInfo, p2: PointInfo) -> void:
	if p1.is_right_edge:
		var p1_map := local_to_map(p1.position)
		var p2_map := local_to_map(p2.position)

		if p2.is_left_edge \
		and p2.position.x > p1.position.x \
		and p2.position.y > p1.position.y \
		and p1_map.distance_to(p2_map) < jump_distance:
			_astar.connect_points(p1.point_id, p2.point_id)
			draw_debug_line(p1.position, p2.position, Color(0, 1, 0, 1))

func connect_diagonal_jump_left_edge_to_right_edge(p1: PointInfo, p2: PointInfo) -> void:
	if p1.is_left_edge:
		var p1_map := local_to_map(p1.position)
		var p2_map := local_to_map(p2.position)

		if p2.is_right_edge \
		and p2.position.x < p1.position.x \
		and p2.position.y > p1.position.y \
		and p1_map.distance_to(p2_map) < jump_distance:
			_astar.connect_points(p1.point_id, p2.point_id)
			draw_debug_line(p1.position, p2.position, Color(0, 1, 0, 1))

func connect_horizontal_platform_jumps(p1: PointInfo, p2: PointInfo) -> void:
	if p1.point_id == p2.point_id:
		return

	# Must be same height, p1 is right edge, p2 is left edge, and p2 is to the right of p1
	if p1.is_right_edge and p2.is_left_edge and p1.position.y == p2.position.y and p2.position.x > p1.position.x:
		var p1_map = local_to_map(p1.position)
		var p2_map = local_to_map(p2.position)

		if p1_map.distance_to(p2_map) < jump_distance + 1:
			_astar.connect_points(p1.point_id, p2.point_id)
			draw_debug_line(p1.position, p2.position, Color(0, 1, 0, 1))

func connect_horizontal_points(p1: PointInfo) -> void:
	if not (p1.is_left_edge or p1.is_left_wall or p1.is_fall_tile):
		return

	var closest: PointInfo = null

	for p2 in _point_info_list:
		if p1.point_id == p2.point_id:
			continue

		if (p2.is_right_edge or p2.is_right_wall or p2.is_fall_tile) \
		and p2.position.y == p1.position.y and p2.position.x > p1.position.x:
			if closest == null or p2.position.x < closest.position.x:
				closest = p2

	if closest != null:
		if not horizontal_connection_cannot_be_made(local_to_map(p1.position), local_to_map(closest.position)):
			_astar.connect_points(p1.point_id, closest.point_id)
			draw_debug_line(p1.position, closest.position, Color(0, 1, 0, 1))

func horizontal_connection_cannot_be_made(p1: Vector2i, p2: Vector2i) -> bool:
	var start_scan := local_to_map(p1)
	var end_scan := local_to_map(p2)

	for x in range(start_scan.x, end_scan.x):
		var above_tile = Vector2i(x, start_scan.y)
		var below_tile = Vector2i(x, start_scan.y + 1)

		if get_cell_source_id(COLLISION_LAYER, above_tile) != CELL_IS_EMPTY \
		or get_cell_source_id(COLLISION_LAYER, below_tile) == CELL_IS_EMPTY:
			return true
	return false

func get_start_scan_tile_for_fall_point(tile: Vector2i) -> Vector2i:
	var tile_above := Vector2i(tile.x, tile.y - 1)
	var point := get_point_info(tile_above)

	if point == null:
		return Vector2i(-1, -1)

	if point.is_left_edge:
		return Vector2i(tile.x - 1, tile.y - 1)
	elif point.is_right_edge:
		return Vector2i(tile.x + 1, tile.y - 1)

	return Vector2i(-1, -1)


func find_fall_point(tile: Vector2) -> Vector2i:
	var scan_start := get_start_scan_tile_for_fall_point(tile)
	if scan_start == null:
		return Vector2i(-1, -1)

	var tile_scan := scan_start
	for i in range(MAX_TILE_FALL_SCAN_DEPTH):
		var below := Vector2i(tile_scan.x, tile_scan.y + 1)
		if get_cell_source_id(COLLISION_LAYER, below) != CELL_IS_EMPTY:
			return tile_scan  # Found solid tile beneath
		tile_scan.y += 1

	return Vector2i(-1, -1)  # No fall tile found within max depth

func add_fall_point(tile: Vector2i) -> void:
	var fall_tile = find_fall_point(tile)
	if fall_tile == Vector2i(-1, -1):
		return

	var fall_tile_local := get_global_tile_center(fall_tile)
	var existing_point_id = tile_already_exists_in_graph(fall_tile)

	if existing_point_id == -1:
		var point_id = _astar.get_available_point_id()
		var point_info = PointInfo.new()
		point_info.point_id = point_id
		point_info.position = fall_tile_local
		point_info.is_fall_tile = true
		_point_info_list.append(point_info)
		_astar.add_point(point_id, fall_tile_local)
		add_visual_point(fall_tile, Color(1, 0.35, 0.1, 1), 0.35)
	else:
		for info in _point_info_list:
			if info.point_id == existing_point_id:
				info.is_fall_tile = true
				break
		add_visual_point(fall_tile, Color("#ef7d57"), 0.30)

func add_left_edge_point(tile: Vector2i) -> void:
	if tile_above_exists(tile):
		return
	
	if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(-1, 0)) == CELL_IS_EMPTY:
		var tile_above := tile + Vector2i(0, -1)
		var existing_point_id := tile_already_exists_in_graph(tile_above)

		if existing_point_id == -1:
			var point_id = _astar.get_available_point_id()
			var point_pos = get_global_tile_center(tile_above)
			var point_info = PointInfo.new()
			point_info.point_id = point_id
			point_info.position = point_pos
			point_info.is_left_edge = true
			_point_info_list.append(point_info)
			_astar.add_point(point_id, point_pos)
			add_visual_point(tile_above)
		else:
			for p in _point_info_list:
				if p.point_id == existing_point_id:
					p.is_left_edge = true
					break
			add_visual_point(tile_above, Color("#73eff7"))

func add_right_edge_point(tile: Vector2i) -> void:
	if tile_above_exists(tile):
		return

	if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(1, 0)) == CELL_IS_EMPTY:
		var tile_above := tile + Vector2i(0, -1)
		var existing_point_id := tile_already_exists_in_graph(tile_above)

		if existing_point_id == -1:
			var point_id = _astar.get_available_point_id()
			var point_pos = get_global_tile_center(tile_above)
			var point_info = PointInfo.new()
			point_info.point_id = point_id
			point_info.position = point_pos
			point_info.is_right_edge = true
			_point_info_list.append(point_info)
			_astar.add_point(point_id, point_pos)
			add_visual_point(tile_above, Color("#94b0c2"))  # blue-gray
		else:
			for p in _point_info_list:
				if p.point_id == existing_point_id:
					p.is_right_edge = true
					break
			add_visual_point(tile_above, Color("#ffcd75"))  # yellow

func add_left_wall_point(tile: Vector2i) -> void:
	if tile_above_exists(tile):
		return

	if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(-1, -1)) != CELL_IS_EMPTY:
		var tile_above := tile + Vector2i(0, -1)
		var existing_point_id := tile_already_exists_in_graph(tile_above)

		if existing_point_id == -1:
			var point_id = _astar.get_available_point_id()
			var point_pos = get_global_tile_center(tile_above)
			var point_info = PointInfo.new()
			point_info.point_id = point_id
			point_info.position = point_pos
			point_info.is_left_wall = true
			_point_info_list.append(point_info)
			_astar.add_point(point_id, point_pos)
			add_visual_point(tile_above, Color(1, 1, 0, 1))  # yellow
		else:
			for p in _point_info_list:
				if p.point_id == existing_point_id:
					p.is_left_wall = true
					break
			add_visual_point(tile_above, Color(0, 0, 1, 1), 0.45)  # small blue

func add_right_wall_point(tile: Vector2i) -> void:
	if tile_above_exists(tile):
		return

	if get_cell_source_id(COLLISION_LAYER, tile + Vector2i(1, -1)) != CELL_IS_EMPTY:
		var tile_above := tile + Vector2i(0, -1)
		var existing_point_id := tile_already_exists_in_graph(tile_above)

		if existing_point_id == -1:
			var point_id = _astar.get_available_point_id()
			var point_pos = get_global_tile_center(tile_above)
			var point_info = PointInfo.new()
			point_info.point_id = point_id
			point_info.position = point_pos
			point_info.is_right_wall = true
			_point_info_list.append(point_info)
			_astar.add_point(point_id, point_pos)
			add_visual_point(tile_above, Color(0, 0, 0, 1))  # black
		else:
			for p in _point_info_list:
				if p.point_id == existing_point_id:
					p.is_right_wall = true  
					break
			add_visual_point(tile_above, Color("#566c86"), 0.65)  # dark blue-purple

func tile_above_exists(tile: Vector2i) -> bool:
	return get_cell_source_id(COLLISION_LAYER, tile + Vector2i(0, -1)) != CELL_IS_EMPTY

func _process(delta: float) -> void:
	pass # Currently does nothing

func get_global_tile_center(tile: Vector2i) -> Vector2:
	return map_to_local(tile)

#func debug_print_astar_points():
	#if _astar == null:
		#print("AStar graph is null")
		#return
	#
	#var ids = _astar.get_point_ids()
	#print("AStar2D contains ", ids.size(), " points.")
	#for id in ids:
		#var pos = _astar.get_point_position(id)
		#print("Point ID:", id, "Position:", pos)
