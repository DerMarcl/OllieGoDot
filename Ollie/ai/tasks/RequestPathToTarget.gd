extends BTAction

@export var target_var: StringName = &"target"
@export var path_var: StringName = &"path"
@export var next_point_var: StringName = &"next_point"

var _last_target_position: Vector2 = Vector2.INF  # Track previous target pos

func _tick(_delta: float) -> Status:
	var target = blackboard.get_var(target_var)
	if target == null or not target is Node2D:
		print("Target not found")
		return FAILURE
	
	var scene_objects = agent.get_tree().current_scene.get_node("SceneObjects")
	var pathfinder = scene_objects.get_node("TileMap_Pirate_used")
	if pathfinder == null:
		print("Pathfinder not found")
		return FAILURE
		
	var start_pos = agent.global_position
	var end_pos = target.global_position

	# Only recalculate if target moved significantly (e.g. more than 16 pixels)
	if _last_target_position != Vector2.INF and _last_target_position.distance_to(end_pos) < 16.0:
		return SUCCESS  # No significant movement; keep current path

	# Update last known position
	_last_target_position = end_pos

	# Generate new path
	var path_stack = pathfinder.get_platform_2d_path(start_pos, end_pos)
	if path_stack.is_empty():
		print("Pathfinder empty")
		return FAILURE
		
	for point in path_stack:
		if typeof(point) == TYPE_DICTIONARY and point.has("position"):
			point["position"] 

	print("New path:", path_stack)

	# Set path and next point
	blackboard.set_var(path_var, path_stack.duplicate(true))  # duplicate so it's not shared
	var peek_first = path_stack[0] if path_stack.size() > 0 else null
	blackboard.set_var(next_point_var, peek_first)

	return SUCCESS
