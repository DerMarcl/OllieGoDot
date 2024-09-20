extends Control
class_name Transitioner

@onready var animation_tex : TextureRect = $TextureRect
@onready var animation_player : AnimationPlayer = $AnimationPlayer

func _ready():
	animation_tex.visible = false

func FadeOut():
	animation_tex.visible = true
	animation_player.queue("FadeOut")

func FadeIn():
	animation_tex.visible = true
	animation_player.queue("FadeIn")
