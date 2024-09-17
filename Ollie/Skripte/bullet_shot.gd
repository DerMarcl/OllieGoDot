extends Area2D

var speed = 800.0
var direction = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("hitbox")
	if direction < 0:
		global_position -= Vector2(50, 0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += speed * delta * direction
	

func _on_hitbox_body_entered(body):
	print("Collision detected with:", body.name)
	if body.is_in_group("Enemy"):
		body.queue_free()
		queue_free()
	if body.is_in_group("Shootable"):
		body.target_hit()
		queue_free()
	if not body.is_in_group("Player"):
		queue_free()
