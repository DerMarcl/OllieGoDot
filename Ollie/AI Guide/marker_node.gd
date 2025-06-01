extends Node2D

@export var initial_position: Vector2 = Vector2.ZERO
@export var radius: float = 6.0
@export var color: Color = Color.BLUE

var has_been_updated := false

func _ready():
	if not has_been_updated:
		global_position = initial_position
	queue_redraw()

func _draw():
	draw_circle(Vector2.ZERO, radius, color)

func update_marker_position(pos: Vector2):
	global_position = pos
	has_been_updated = true
	queue_redraw()
