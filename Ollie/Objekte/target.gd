extends RigidBody2D

@onready var sprite_2d = $Sprite2D
@export var is_air = true
@export var event_to_trigger: String = "" 
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Shootable")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass



func target_hit():
	if is_air:
		sprite_2d.animation = "destroyed_air"
	else:
		sprite_2d.animation = "destroyed"
	
	if event_to_trigger != "":
		EventManager.trigger_event(event_to_trigger)

func _on_sprite_2d_animation_finished():
	if sprite_2d.animation == "destroyed_air" or sprite_2d.animation == "destroyed":
		queue_free()


func _on_body_entered(body):
	print("yooooo2")
	if body.is_in_group("hitbox"):
		print("yooooo")
