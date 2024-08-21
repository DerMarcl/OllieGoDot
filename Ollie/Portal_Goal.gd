extends Area2D

@export var target_level : PackedScene


func _ready():
	pass

func _on_body_entered(body):
	if(body.name == "Ollie"):
		body.in_portal = true
		body.current_portal = self

func _on_body_exited(body):
	if(body.name == "Ollie"):
		body.in_portal = false
		body.current_portal = null

func level_transition():
	get_tree().change_scene_to_packed(target_level)
