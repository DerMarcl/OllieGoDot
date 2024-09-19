extends CharacterBody2D
@onready var game_manager = %GameManager
@export var doesRespawn = false
@export var doesMove = false
@export var speed : int = 100

var direction = 1
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var Good_to_turn = true
# Called when the node enters the scene tree for the first time.
func _ready():
	if $Hit_buffer:
		$Hit_buffer.one_shot = true
	add_to_group("Enemy")
	if not doesRespawn:
		if GameManager.is_despawned(name):
			queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if doesMove:
		move_and_slide()
		velocity.y += gravity * delta
		velocity.x = speed * direction
		


func _on_area_2d_body_entered(body):
	
	if body.is_in_group("Player"):
		var y_delta = position.y - body.position.y
		var x_delta = body.position.x - position.x
		if(y_delta > 30):
			print("enemy defeated")
			GameManager.mark_as_despawned(name)
			queue_free()
			body.jump()
		else:
			print("Lost Life")
			game_manager.decrease_healh()
			if Global.lives != 3:
				if(x_delta > 0):
					body.jump_slide(500)
				else:
					body.jump_slide(-500)


func _on_attackbox_body_entered(body):
	print(body.name)
	print(direction)
	if body.is_in_group("Player"):
		game_manager.decrease_healh()
		if Global.lives != 3:
			if direction > 0:
				body.jump_slide(500)
			else:
				body.jump_slide(-500)
	elif Good_to_turn and doesMove and body.name != name:
		direction *= -1
		Good_to_turn = false
		$Hit_buffer.start()
		self.scale.x *= -1


func _on_hit_buffer_timeout():
	Good_to_turn = true
