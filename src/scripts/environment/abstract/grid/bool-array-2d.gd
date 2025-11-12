class_name BoolArray2D
extends RefCounted

var rows: Array[BoolArray1D] = []

func _init(width: int = 0, height: int = 0, default: bool = false) -> void:
	rows.resize(height)
	for y in range(height):
		rows[y] = BoolArray1D.new(width, default)

func get_at(x: int, y: int) -> bool:
	return rows[y].get_at(x)

func set_at(x: int, y: int, v: bool) -> void:
	rows[y].set_at(x, v)

func width() -> int:
	if rows.is_empty():
		return 0
	else:
		return rows[0].size()

func height() -> int:
	return rows.size()
