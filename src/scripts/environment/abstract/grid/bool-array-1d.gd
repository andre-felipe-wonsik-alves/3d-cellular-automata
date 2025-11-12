class_name BoolArray1D
extends RefCounted

var values: Array[bool] = []

func _init(size: int = 0, default: bool = false) -> void:
	values.resize(size)
	for i in range(size):
		values[i] = default

func size() -> int:
	return values.size()

func get_at(i: int) -> bool:
	return values[i]

func set_at(i: int, v: bool) -> void:
	values[i] = v
