extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -900.0

const ACCELERATION_TIME = 0.04 # time to reach full speed on the ground
const DECELERATION_TIME = 0.04 # time to fully stop on the ground
const AIR_INERTIA_MULTIPLIER = 3.0 # inertia multiplier when in the air
const COYOTE_TIME = 0.2 # time in seconds to allow jumping after leaving the ground
const WALLJUMP_GRACE = 0.3 #time after walljump where pressing the opposite way doesnt do anything

@onready var sprite_2d = $Sprite2D


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var acceleration = SPEED / ACCELERATION_TIME
var deceleration = SPEED / DECELERATION_TIME
var has_walljump = false
var has_backwards_walljump = true

var coyote_timer = 0.0 # tracks how long we've been off the ground
var grace_timer = 0.0 # tracks how long since last wall jump
var in_portal = false #track if the player is in the portal area

var current_portal: Area2D = null

func jump():
	velocity.y = JUMP_VELOCITY
func jump_slide(x):
	velocity.y = JUMP_VELOCITY
	velocity.x = x

func _physics_process(delta):
	var is_in_air = not is_on_floor()
	var inertia_multiplier = AIR_INERTIA_MULTIPLIER if is_in_air else 1.0
	
	# Determine the acceleration and deceleration based on whether the character is in the air
	var adjusted_acceleration = acceleration / inertia_multiplier
	var adjusted_deceleration = deceleration / inertia_multiplier
	
	var wallslide = is_on_wall_only() and (has_walljump or has_backwards_walljump)
	# Handle coyote time
	if is_on_floor():
		coyote_timer = COYOTE_TIME # Reset the coyote timer if on the ground
	else:
		coyote_timer = max(coyote_timer - delta, 0) # Decrease the timer if in the air
	
	if (velocity.x > 1 || velocity.x < -1):
		sprite_2d.animation = "running"
	else:
		sprite_2d.animation = "default"
	var direction = Input.get_axis("left", "right")
	# Add the gravity.
	
	if is_on_wall_only() and ((direction < 0 and sprite_2d.flip_h) or (direction > 0 and not sprite_2d.flip_h)):
		has_walljump = true
	else:
		has_walljump = false
		
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y >= 1000:
			velocity.y = 1000
		sprite_2d.animation = "jumping"
		if velocity.y >= 300 and wallslide:
			velocity.y = 300
	else:
		has_backwards_walljump = true
	
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and ((is_on_floor() or coyote_timer > 0.0) or (is_on_wall_only() and direction and (has_walljump or has_backwards_walljump))):
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0 # Reset the coyote timer after a jump
		
		if wallslide:
			velocity.x = -direction * SPEED 
			sprite_2d.flip_h = (velocity.x < 0)
			has_backwards_walljump = false
			grace_timer = WALLJUMP_GRACE
			
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	grace_timer = max(grace_timer - delta, 0)
	if grace_timer == 0:
		if direction:
			velocity.x = move_toward(velocity.x, direction * SPEED, adjusted_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, adjusted_deceleration * delta)
	move_and_slide()
	
	if velocity.x != 0 and is_on_floor():
		var isLeft = velocity.x < 0
		sprite_2d.flip_h = isLeft 
	

	if in_portal and Input.is_action_just_pressed("up") and is_on_floor():
		current_portal.level_transition()
		
