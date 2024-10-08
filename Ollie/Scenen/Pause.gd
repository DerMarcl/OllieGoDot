extends Node
@onready var pause_panel = %PausePanel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var esc_pressed = Input.is_action_just_pressed("pause")
	if(esc_pressed == true):
		get_tree().paused = true
		pause_panel.show()



func _on_resume_pressed():
	pause_panel.hide()
	get_tree().paused = false

func _on_main_menu_pressed():
	get_tree().paused = false
	GameManager.reset_on_Level_end()
	get_tree().change_scene_to_file("res://Scenen/TestLevels/LevelOverworld.tscn")

func _on_hauptmenu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenen/main_menu.tscn")
