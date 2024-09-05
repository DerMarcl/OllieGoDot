extends Node

@onready var coins_label = $Panel/CoinsLabel

func _ready():
	GameManager.set_main_scene(self)
	update_coins_label()

func update_coins_label():
	coins_label.text = "Coins: " + str(Global.coins)


