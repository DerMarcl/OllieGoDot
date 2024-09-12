extends CharacterBody2D


# Parameter für das automatische Laufen und Springen
@export var move_speed: float = 400.0
@export var jump_force: float = 600.0
@export var gravity: float = 1200.0

# Variable um den aktuellen Bewegungszustand zu speichern
var velo: Vector2 = Vector2()

func _physics_process(delta: float) -> void:
	# Schwerkraft anwenden
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Bewege den Charakter nach vorne
	velocity.x = move_speed
	
	# Überprüfen, ob die Leertaste zum Springen gedrückt wird und der Charakter auf dem Boden ist
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
	# Setze die Bewegung des Characters
	move_and_slide()

