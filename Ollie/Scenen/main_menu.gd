extends Node

func _on_level_1_pressed():
	GameManager.current_level_id = 1
	get_tree().change_scene_to_file("res://Scenen/Pirate level 1/Pirate1-1.tscn")


func _on_level_2_pressed():
	GameManager.current_level_id = 2
	get_tree().quit()
