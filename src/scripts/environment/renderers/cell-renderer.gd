extends Node3D
class_name CellRenderer

var cube_scene: PackedScene
var cell_size: float = 1.0
var base_y: float = 0.0

var size_x: int
var size_y: int
var size_z: int

var cubes: Dictionary[Vector3i, Node3D] = {} 

func setup(p_cube_scene: PackedScene, p_cell_size: float, p_base_y: float) -> void:
	cube_scene = p_cube_scene
	cell_size = p_cell_size
	base_y = p_base_y

func build_from_grid(grid: GridController) -> void:
	for child in get_children():
		child.queue_free()
	cubes.clear()

	size_x = grid.size_x
	size_y = grid.size_y
	size_z = grid.size_z

	for x in range(size_x):
		for y in range(size_y):
			for z in range(size_z):
				var cube: Node3D = cube_scene.instantiate()
				cube.position = _cell_to_world_pos(x, y, z)
				cube.visible = grid.cells.get_at(x, y, z)
				add_child(cube)
				cubes[Vector3i(x, y, z)] = cube

func update_from_grid(grid: GridController) -> void:
	for x in range(size_x):
		for y in range(size_y):
			for z in range(size_z):
				var key := Vector3i(x, y, z)
				var cube: Node3D = cubes.get(key)
				if cube:
					var alive: bool = grid.cells.get_at(x, y, z)
					cube.visible = alive

func _cell_to_world_pos(x: int, y: int, z: int) -> Vector3:
	var offset_x := (x - (size_x / 2.0) + 0.5) * cell_size
	var offset_y := base_y + (y + 0.5) * cell_size
	var offset_z := (z - (size_z / 2.0) + 0.5) * cell_size
	return Vector3(offset_x, offset_y, offset_z)
