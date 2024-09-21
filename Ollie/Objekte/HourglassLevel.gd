extends Area2D

func _on_body_entered(body):
	if (body.name == "Ollie"):
		GameManager.mark_as_despawned(name)
		queue_free()

