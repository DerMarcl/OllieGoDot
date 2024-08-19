extends RigidBody2D
@onready var game_manager = %GameManager

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_area_2d_body_entered(body):
	if(body.name == "Ollie"):
		var y_delta = position.y - body.position.y
		var x_delta = body.position.x - position.x
		if(y_delta > 30):
			print("enemy defeated")
			queue_free()
			body.jump()
		else:
			print("Lost Life")
			game_manager.decrease_healh()
			if(x_delta > 0):
				body.jump_slide(500)
			else:
				body.jump_slide(-500)
