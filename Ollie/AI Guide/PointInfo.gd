# res://scripts/PointInfo.gd
class_name PointInfo

var point_id: int
var position: Vector2
var is_fall_tile := false
var is_left_edge := false
var is_right_edge := false
var is_left_wall := false
var is_right_wall := false
var is_position_point := false

func _init(id: int = -1, pos: Vector2 = Vector2.ZERO):
	point_id = id
	position = pos
