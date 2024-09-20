extends Area2D

@export var target_level : int = 0
@export var on_touch_transition : bool = true
@export var target_spawnpoint: int = 0


@export var Requirement: GameManager.PossiblePowers = GameManager.PossiblePowers.NORMAL


func _ready():
	pass

func _on_body_entered(body):
	if body.is_in_group("Player"):
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

func level_transition():
	Global.cur_coins = 0
	Global.target_spawnpoint = target_spawnpoint
	GameManager.level_selector(target_level)
