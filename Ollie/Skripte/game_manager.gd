extends Node

@onready var coins_label = $"../UI/Panel/CoinsLabel"
@export var hearts : Array[Node]

var main_scene = null
var current_level_id = 1
var despawned_objects = []

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
	Global.cur_power = GameManager.PossiblePowers.NORMAL


#Level selector
func level_selector(level_id: int):
	current_level_id = level_id
	call_deferred("_level_selector_deferred")

func _level_selector_deferred():
	match current_level_id:
		1:
			get_tree().change_scene_to_file("res://Scenen/TestLevels/testlevel.tscn")
		2:
			get_tree().change_scene_to_file("res://Scenen/TestLevels/level2.tscn")
		_:
			get_tree().change_scene_to_file("res://Scenen/main_menu.tscn")
			
	
# Despawning logic
# Mark an object as despawned by its name and the level ID
func mark_as_despawned(object_name: String):
	var unique_id = object_name + "_" + str(current_level_id)  # Combine name and level ID
	print(unique_id)
	if unique_id not in despawned_objects:
		despawned_objects.append(unique_id)

# Check if an object is despawned by its name and the level ID
func is_despawned(object_name: String) -> bool:
	var unique_id = object_name + "_" + str(current_level_id)  # Combine name and level ID
	return unique_id in despawned_objects
