extends CharacterBody2D

@export var move_speed = 100  # The speed at which the platform moves
@export var point_a: Vector2  # One end of the movement path
@export var point_b: Vector2  # The other end of the movement path
@export var event_name = ""
@export var wait_cooldown = 1.0
@export var stops_at_Checkpoint = true
var target_point: Vector2     # The current target point to move towards
var is_moving = true


func _ready():
	# Set the initial target point to move to
	point_a = point_a + position
	point_b = point_b + position
	target_point = point_b
	$Wait_Timer.wait_time = float(wait_cooldown)
	$Wait_Timer.one_shot = true
	if event_name != "":
		if EventManager.is_event_triggered(event_name):
			is_moving = true  # If the event has already been triggered, start moving
		else:
			is_moving = false  # Disable movement and wait for the event
			EventManager.connect("event_triggered", self._on_event_triggered)
	else:
		is_moving = true  # No event, platform moves by default

func _physics_process(delta):
	if is_moving:
		move_platform(delta)

func move_platform(_delta):
	# Calculate the direction towards the target point
	
	var direction_vector = (target_point - position).normalized()

	# Set the platform's velocity based on direction and speed
	velocity = direction_vector * move_speed 

	# Move the platform using move_and_slide (no external forces will affect it)
	move_and_slide()

	# Check if the platform is close to the target point
	if position.distance_to(target_point) < 5.0:
		switch_target()
		if stops_at_Checkpoint:
			is_moving = false
			$Wait_Timer.start()

func switch_target():
	# Switch target points once the platform reaches one end
	if target_point == point_b:
		target_point = point_a
	else:
		target_point = point_b
		
func _on_event_triggered(triggered_event_name: String):
	if triggered_event_name == event_name:
		is_moving = true
		
	
func _on_wait_timer_timeout():
	is_moving = true
