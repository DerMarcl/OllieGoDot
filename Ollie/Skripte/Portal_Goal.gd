extends Area2D

@export var target_level : int = 0
@export var on_touch_transition : bool = true
@export var target_spawnpoint: int = 0
@export var ends_level = false
var transition


@export var is_goal = false
@onready var arrow_up = $ArrowUp

@export var Requirement: GameManager.PossiblePowers = GameManager.PossiblePowers.NORMAL


func _ready():
	$FadeOutTimer.one_shot = true
	call_deferred("_find_transition")
	pass
func _find_transition():
	var scene_objects = get_tree().current_scene.get_node("SceneObjects")
	var ollie_object = scene_objects.get_node("Ollie")
	var camera_object = ollie_object.get_node("Camera2D")
	transition = camera_object.get_node("Transition")
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		arrow_up.visible = true
		if on_touch_transition:
			level_transition()
		else:
			body.in_portal = true
			body.current_portal = self

		if Requirement == GameManager.PossiblePowers.NORMAL or body.power_state == Requirement:
			if on_touch_transition:
				level_transition()
			else:
				body.in_portal = true
				body.current_portal = self


func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.in_portal = false
		body.current_portal = null
		arrow_up.visible = false

func level_transition():
	transition.FadeOut()
	$FadeOutTimer.start()
	

func _on_fade_out_timer_timeout():
	Global.cur_coins = 0
	Global.target_spawnpoint = target_spawnpoint
	if ends_level:
		GameManager.reset_on_Level_end()
	GameManager.level_selector(target_level)

