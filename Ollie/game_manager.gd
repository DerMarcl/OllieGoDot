extends Node

@onready var coins_label = $"../UI/Panel/CoinsLabel"
@export var hearts : Array[Node]

var main_scene = null
var switch_level_id = 0

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
<<<<<<< HEAD
	
func levelselector(level_id: int):
	match level_id:
=======
	Global.cur_power = GameManager.PossiblePowers.NORMAL



func level_selector(level_id: int):
	switch_level_id = level_id
	call_deferred("_level_selector_deferred")

func _level_selector_deferred():
	match switch_level_id:
>>>>>>> cc0a6a765d0f8ac3862ba71ce0e9da82051caff9
		1:
			get_tree().change_scene_to_file("res://Scenen/TestLevels/testlevel.tscn")
		2:
			get_tree().change_scene_to_file("res://Scenen/TestLevels/level2.tscn")
		_:
			get_tree().change_scene_to_file("res://Scenen/main_menu.tscn")
<<<<<<< HEAD

=======
			
>>>>>>> cc0a6a765d0f8ac3862ba71ce0e9da82051caff9
	

