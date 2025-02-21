extends BTAction

@export var target_var := &"target"

@export var tolerance = 10

func _tick (_delta: float) -> Status:
	
	var target: CharacterBody2D = blackboard.get_var(target_var)
	
	if target == null:
		return FAILURE
	
	var target_position = target.global_position
	var distance2D = agent.global_position.direction_to(target_position)
	var dir = 1
	
	if distance2D.x > 0:
		dir = 1
	elif distance2D.x < 0:
		dir = -1
	else:
		dir = 0
	
	if abs(agent.global_position.x - target.global_position.x) < tolerance:
		agent.set_direction(0)
		if agent.has_method("perform_jump"):
			agent.perform_jump()
		return SUCCESS
	else:
		agent.set_direction(dir)
		
	if agent.is_obstacle_in_front and agent.is_on_floor():
		agent.perform_jump()
	return RUNNING
