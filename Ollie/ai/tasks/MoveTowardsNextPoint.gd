extends BTAction

@export var target_var: StringName = &"next_point"
@export var tolerance: float = 16.0
@export var jump_threshold: float = 25.0  # How much higher the target must be to consider jumping

func _tick(_delta: float) -> Status:
	var step: Dictionary = blackboard.get_var(target_var)
	if step == null or not step.has("position"):
		print("No next_point or invalid format")
		return FAILURE

	var target_pos: Vector2 = step["position"]
	var agent_pos: Vector2 = agent.global_position

	var horizontal_distance = target_pos.x - agent_pos.x
	var vertical_distance = target_pos.y - agent_pos.y
	var dir = 0

	# Determine if horizontal movement is needed
	if horizontal_distance > tolerance:
		dir = 1
	elif horizontal_distance < -tolerance:
		dir = -1

	# Set direction
	agent.set_direction(dir)

	# Check if a jump is needed (we assume jumping is only needed if the target is clearly higher)
	if vertical_distance > jump_threshold and agent.is_on_floor():
		print("Boing~")
		print(target_pos.y)
		print(target_pos.x)
		agent.jump()

	# If we're close enough horizontally and vertically, task is complete
	if abs(horizontal_distance) <= tolerance and abs(vertical_distance) <= jump_threshold:
		agent.set_direction(0)
		print("Reached a point. Success!")
		return SUCCESS

	return RUNNING
