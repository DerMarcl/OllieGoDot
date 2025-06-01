extends Node2D

var radius: float = 6.0
var color: Color = Color.BLUE

func _draw():
	draw_circle(Vector2.ZERO, radius, color)
	z_index = 1000
