extends Area2D

var speed = 800.0
var direction = -1


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("hitbox")
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
		global_position -= Vector2(150, 0)

		
func _on_hitbox_body_entered(body):
	if body.is_in_group("Enemy"):
		print("Bonk")
		body.queue_free()
	if body.is_in_group("Bonkable"):
		body.box_hit()



func _on_animated_sprite_2d_animation_looped():
	queue_free()




func _on_hitbox_area_entered(area):
	if area.is_in_group("Bonkable"):
		area.hit()
