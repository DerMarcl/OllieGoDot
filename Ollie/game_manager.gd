extends Node

var coins = 0
var lives = 3
@onready var coins_label = $"../UI/Panel/CoinsLabel"
@export var hearts : Array[Node]

func add_coins():
	coins += 1
	print(coins)
	coins_label.text = "Coins: " + str(coins)
	
func decrease_healh():
	lives -= 1
	print(lives)
	for h in 3:
		if(h < lives):
			hearts[h].show()
		else:
			hearts[h].hide()
	if(lives <= 0):
		get_tree().reload_current_scene()
