extends Area2D

@onready var game_manager = %GameManager
@onready var coin_sound = $coin_sound

func _ready():
	if GameManager.is_despawned(name):
		queue_free()

func _on_body_entered(body):
	if (body.name == "Ollie"):
		coin_sound.play()
		GameManager.mark_as_despawned(name)
		queue_free()
		game_manager.add_coins()
	if (body.name == "DinoRider"):
		coin_sound.play()
		queue_free()
		game_manager.add_coins()
