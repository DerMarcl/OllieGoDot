extends CharacterBody2D

@export var is_moving : bool = true
@export var is_floating : bool = false
@export var speed : int = 100
@onready var sprite_2d = $Sprite2D

var direction = -1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var hit_ground = false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D2.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	sprite_2d.animation = "default"
	move_and_slide()
	if is_on_floor():
		hit_ground = true
	if is_floating:
		velocity.y = 0
	else:
		velocity.y += gravity * delta
		
	if is_moving and hit_ground:
		velocity.x = speed * direction
	else:
		velocity.x = 0

func _on_body_entered(body):
	if(body.name == "Ollie"):
		body.powerStateChange(body.PossiblePowers.PIRATE)
		queue_free()
	else:
		direction *= -1
