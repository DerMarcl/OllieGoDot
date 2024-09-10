extends Area2D

@onready var game_manager = %GameManager

func _ready():
	if GameManager.is_despawned(name):
		queue_free()

func _on_body_entered(body):
	if (body.name == "Ollie"):
		GameManager.mark_as_despawned(name)
		queue_free()
		game_manager.add_coins()
