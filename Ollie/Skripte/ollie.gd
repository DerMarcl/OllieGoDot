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

var direction
var cur_direction = 1
var acceleration = SPEED / ACCELERATION_TIME
var deceleration = SPEED / DECELERATION_TIME
var has_walljump = false
var has_backwards_walljump = true
var does_spcial_action = false
var does_moveable_action = false

var coyote_timer = 0.0 # tracks how long we've been off the ground
var grace_timer = 0.0 # tracks how long since last wall jump
var in_portal = false #track if the player is in the portal area

var current_portal: Area2D = null

var power_state: GameManager.PossiblePowers = GameManager.PossiblePowers.NORMAL

func jump():
	velocity.y = JUMP_VELOCITY
func jump_slide(x):
	velocity.y = JUMP_VELOCITY
	velocity.x = x

func _ready():
	power_state = Global.cur_power
	call_deferred("_find_spawn_container")
	$hitbox_Timer_Bonk.one_shot = true
	$gun_out_timer.one_shot = true
	
func _find_spawn_container():
	var scene_objects = get_tree().current_scene.get_node("SceneObjects")
	var spawn_container = scene_objects.get_node("Portals_and_Spawns")

	
	var spawn_points = spawn_container.get_children()

	for spawn_point in spawn_points:
		if spawn_point is SpawnPoint and spawn_point.spawn_index == Global.target_spawnpoint:
			position = spawn_point.global_position
			break

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
	
	direction = Input.get_axis("left", "right")
	
	#animation corner:
	if not does_spcial_action and not does_moveable_action:
		match power_state:
			GameManager.PossiblePowers.NORMAL:
				if not is_on_floor():
					sprite_2d.animation = "jumping"
				elif (velocity.x > 1 || velocity.x < -1):
					sprite_2d.animation = "running"
				else:
					sprite_2d.animation = "default"
				
			GameManager.PossiblePowers.PIRATE:
				if not is_on_floor():
					sprite_2d.animation = "Pirate_jump"
				elif (velocity.x > 1 || velocity.x < -1):
					sprite_2d.animation = "Pirate_run"
				else:
					sprite_2d.animation = "Pirate_idle"
			GameManager.PossiblePowers.CAVEMAN:
				if not is_on_floor():
					sprite_2d.animation = "Caveman_jump"
				elif (velocity.x > 1 || velocity.x < -1):
					sprite_2d.animation = "Caveman_run"
				else:
					sprite_2d.animation = "Caveman_idle"
	# Add the gravity.
	
	if is_on_wall_only() and ((direction < 0 and sprite_2d.flip_h) or (direction > 0 and not sprite_2d.flip_h)):
		has_walljump = true
	else:
		has_walljump = false
		
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y >= 1000:
			velocity.y = 1000
		if velocity.y >= 300 and wallslide:
			velocity.y = 300
	else:
		has_backwards_walljump = true
	
	
	if power_state != GameManager.PossiblePowers.NORMAL and Input.is_action_just_pressed("action"):
		if power_state == GameManager.PossiblePowers.PIRATE:
			shoot_bullet()
		if power_state == GameManager.PossiblePowers.CAVEMAN and not does_spcial_action:
			club_slash()
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and not does_spcial_action and ((is_on_floor() or coyote_timer > 0.0) or (is_on_wall_only() and direction and (has_walljump or has_backwards_walljump))):
		velocity.y = JUMP_VELOCITY 
		coyote_timer = 0.0 # Reset the coyote timer after a jump
		
		if wallslide:
			velocity.x = -direction * SPEED 
			sprite_2d.flip_h = (velocity.x < 0)
			cur_direction = direction
			has_backwards_walljump = false
			grace_timer = WALLJUMP_GRACE
			
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	grace_timer = max(grace_timer - delta, 0)
	if grace_timer == 0:
		if direction and not does_spcial_action:
			velocity.x = move_toward(velocity.x, direction * SPEED, adjusted_acceleration * delta)
		elif does_spcial_action:
			velocity.x = move_toward(velocity.x, 0, adjusted_deceleration * delta * 0.3)
		else:
			velocity.x = move_toward(velocity.x, 0, adjusted_deceleration * delta)
	move_and_slide()
	
	if velocity.x != 0 and is_on_floor():
		var isLeft = velocity.x < 0
		sprite_2d.flip_h = isLeft 
		cur_direction = direction
	

	if in_portal and Input.is_action_just_pressed("up") and is_on_floor():
		current_portal.level_transition()
		
	if sprite_2d.flip_h:
		cur_direction = -1
	else:
		cur_direction = 1
	
	
func powerStateChange(new_power_state : GameManager.PossiblePowers):
	power_state = new_power_state
	Global.cur_power = new_power_state
	print("PowerUp")



func shoot_bullet():
	var BulletShotScene = load("res://Objekte/bullet_shot.tscn")
	var Bullet = BulletShotScene.instantiate()
	Bullet.global_position = global_position
	
	Bullet.direction = cur_direction
	get_parent().add_child(Bullet)
	sprite_2d.animation = "Pirate_shoot"
	does_moveable_action = true
	$gun_out_timer.start()
	
func club_slash():
	print("smash")
	$hitbox_Timer_Bonk.start()
	does_spcial_action = true
	sprite_2d.animation = "BigBonk"

func _on_sprite_2d_animation_looped():
	if sprite_2d.animation == "BigBonk":
		does_spcial_action = false

func _on_hitbox_timer_bonk_timeout():
	print("timeout")
	var SlashScene = load("res://Objekte/Slash.tscn")
	var Slash = SlashScene.instantiate()
	Slash.global_position = global_position
	
	Slash.direction = cur_direction
	get_parent().add_child(Slash)

func _on_gun_out_timer_timeout():
	does_moveable_action = false
