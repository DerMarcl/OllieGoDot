extends Node

@onready var coins_label = $"../UI/Panel/CoinsLabel"
@export var hearts : Array[Node]

var main_scene = null

enum PossiblePowers {
	NORMAL,
	PIRATE,
	CAVEMAN
}

func set_main_scene(scene):
	main_scene = scene

func add_coins():
	Global.coins += 1
	Global.cur_coins += 1
	print(Global.coins)
	coins_label.text = "Coins: " + str(Global.coins)
	
func set_coins(new_coins : int):
	Global.coins = new_coins
	print(new_coins)
	coins_label.text = "Coins: " + str(Global.coins)
	
func decrease_healh():
	Global.lives -= 1
	print(Global.lives)
	for h in 3:
		if(h < Global.lives):
			hearts[h].show()
		else:
			hearts[h].hide()
	if(Global.lives <= 0):
		respawn()

func respawn():
	get_tree().reload_current_scene()
	Global.coins = Global.coins - Global.cur_coins
	Global.cur_coins = 0
	Global.lives = 3
	

	

