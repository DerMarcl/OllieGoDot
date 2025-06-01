extends BTAction

@export var target_var: StringName = &"next_point"
@export var previous_var: StringName = &"previous_point"
@export var max_jump_threshold := 16.0 # pixels

func _tick(_delta: float) -> Status:
	var target = blackboard.get_var(target_var)
	var previous = blackboard.get_var(previous_var)

	if target == null or previous == null:
		return FAILURE  # this is a critical problem

	var step: Dictionary = blackboard.get_var(target_var)
	if step == null or not step.has("position"):
		print("Missing or malformed next_point")
		return FAILURE

	var target_pos: Vector2 = step["position"]
	var dy = target_pos.y - agent.global_position.y

	# Only jump if on floor and the target is significantly higher
	if agent.is_on_floor() and dy < -max_jump_threshold:
		if agent.has_method("perform_jump"):
			agent.perform_jump()
			return RUNNING
		else:
			return FAILURE  # can't jump at all? critical

	# No jump needed, but not a failure!
	return SUCCESS
