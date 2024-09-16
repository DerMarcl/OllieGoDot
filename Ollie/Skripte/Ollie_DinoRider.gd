extends CharacterBody2D


# Parameter für das automatische Laufen und Springen
@export var move_speed: float = 400.0
@export var jump_force: float = -600.0
@export var gravity: float = 1200.0

# Variable um den aktuellen Bewegungszustand zu speichern
var velo: Vector2 = Vector2()
var is_in_air = false
var knockback = false
var timer = false

func jump():
	velocity.y = jump_force
func jump_slide(x):
	velocity.y = jump_force
	velocity.x = x/2
	knockback = true
	timer = true
	$Knockback_Timer.start()
	

func _ready():
	add_to_group("Player")
	$Knockback_Timer.one_shot = true
	
func _physics_process(delta: float) -> void:
	is_in_air = not is_on_floor()
	
	if is_in_air:
		velocity.y += gravity * delta
	
	if knockback and not is_in_air and not timer:
		knockback = false
	
	if not knockback:
		velocity.x = move_speed
	
	# Überprüfen, ob die Leertaste zum Springen gedrückt wird und der Charakter auf dem Boden ist
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	# Setze die Bewegung des Characters
	move_and_slide()

func _on_knockback_timer_timeout():
	timer = false
