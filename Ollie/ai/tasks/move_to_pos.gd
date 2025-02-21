extends BTAction

@export var target_pos_var := &"pos"
@export var dir_var := &"dir"

@export var tolerance = 10

func _tick (_delta: float) -> Status:
	
	var target_pos: Vector2 = blackboard.get_var(target_pos_var, Vector2.ZERO)
	var dir = blackboard.get_var(dir_var)
	
	if abs(agent.global_position.x - target_pos.x) < tolerance or agent.is_obstacle_in_front:
		agent.set_direction(0)
		if agent.has_method("perform_jump"):
			agent.perform_jump()
		return SUCCESS
	else:
		agent.set_direction(dir)
		return RUNNING
