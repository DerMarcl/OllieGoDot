extends RigidBody2D

var hits_taken = 0
@export var max_hits = 3
@export var hit_cooldown = 0.5
@onready var sprite_2d = $Sprite2D
var can_be_hit = true

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Bonkable")
	$Timer.wait_time = hit_cooldown
	$Timer.one_shot = true
	if GameManager.is_despawned(name):
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Dont need them right now. Who knows. Maybe later.
#func _process(delta):
	#pass

func box_hit():
	if can_be_hit:
		hits_taken += 1
		can_be_hit = false  # Disable further hits

		# Start the cooldown timer
		$Timer.start()

		# Check if hits exceed the limit
		if hits_taken >= max_hits:
			queue_free()  # Destroy the box
			GameManager.mark_as_despawned(name)
		else:
			sprite_2d.animation = "Hit" 


func _on_timer_timeout():
	can_be_hit = true  # Allow the box to be hit again


func _on_sprite_2d_animation_looped():
	if sprite_2d.animation == "Hit":
		sprite_2d.animation = "default"
