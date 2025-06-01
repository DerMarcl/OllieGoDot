extends Node2D

var lines := []  # Stores line data as dictionaries

func _draw():
	for line in lines:
		draw_line(line["from"], line["to"], line["color"], 2.0)


func add_line(from: Vector2, to: Vector2, color: Color) -> void:
	lines.append({ "from": from*3, "to": to*3, "color": color })
	queue_redraw()

func clear_lines() -> void:
	lines.clear()
	queue_redraw()
