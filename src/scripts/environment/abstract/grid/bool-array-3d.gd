class_name BoolArray3D
extends RefCounted

var layers: Array[BoolArray2D] = []

func _init(width: int = 0, height: int = 0, depth: int = 0, default: bool = false) -> void:
	layers.resize(depth)
	for z in range(depth):
		layers[z] = BoolArray2D.new(width, height, default)

func get_at(x: int, y: int, z: int) -> bool:
	return layers[z].get_at(x, y)

func set_at(x: int, y: int, z: int, v: bool) -> void:
	layers[z].set_at(x, y, v)

func depth() -> int:
	return layers.size()
