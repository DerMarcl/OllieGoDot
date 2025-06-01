extends BTAction

@export var path_var: StringName = &"path"
@export var next_point_var: StringName = &"next_point"
@export var previous_point_var: StringName = &"previous_point"

func _tick(_delta: float) -> Status:
	var path: Array = blackboard.get_var(path_var, [])

	if path.is_empty():
		blackboard.set_var(next_point_var, null)
		return FAILURE

	# Move current point to previous
	var current_next_point = blackboard.get_var(next_point_var)
	print("Current full path:", path)
	if current_next_point != null:
		blackboard.set_var(previous_point_var, current_next_point)

	# Advance to next point
	var new_next = path.pop_back() 
	blackboard.set_var(next_point_var, new_next)
	blackboard.set_var(path_var, path)
	
	return SUCCESS
