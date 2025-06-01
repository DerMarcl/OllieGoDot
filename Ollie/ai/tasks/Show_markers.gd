extends BTAction

@export var path_var: StringName = &"path"
@export var marker_scene: PackedScene = preload("res://AI Guide/marker_helper_node.tscn")
@export var marker_parent_path: NodePath = "MarkerContainer"  # Path in the scene where markers go

func _tick(_delta: float) -> Status:
	var path: Array = blackboard.get_var(path_var, [])
	if path.is_empty():
		return FAILURE
	var parent = agent.get_tree().current_scene.get_node_or_null(marker_parent_path)
	if parent == null:
		push_error("Marker container node not found.")
		return FAILURE

	# Clear existing markers
	for child in parent.get_children():
		child.queue_free()

	# Add one marker for each path point
	for point in path:
		if typeof(point) == TYPE_DICTIONARY and point.has("position"):
			var marker = marker_scene.instantiate()
			marker.position = point["position"]
			parent.add_child(marker)

	return SUCCESS
