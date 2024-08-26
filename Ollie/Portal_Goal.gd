extends Area2D

@export var target_level : PackedScene
@export var on_touch_transition : bool = true

func _ready():
	pass

func _on_body_entered(body):
	if(body.name == "Ollie"):
		if on_touch_transition:
			get_tree().change_scene_to_packed(target_level)
		else:
			body.in_portal = true
			body.current_portal = self

func _on_body_exited(body):
	if(body.name == "Ollie"):
		body.in_portal = false
		body.current_portal = null

func level_transition():
	Global.cur_coins = 0
	get_tree().change_scene_to_packed(target_level)
