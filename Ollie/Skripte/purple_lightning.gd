extends Area2D

var Zap_ready = true
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.one_shot = true


func _on_body_entered(body):
	if body.is_in_group("Player"):
		if body.power_state != GameManager.PossiblePowers.NORMAL and Zap_ready:
			body.Zap_powerup()
			$Timer.start()
			$AnimatedSprite2D.visible = false
			Zap_ready = false

func _on_timer_timeout():
	$AnimatedSprite2D.visible = true
	Zap_ready = true
