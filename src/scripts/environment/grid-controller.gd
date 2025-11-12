extends RefCounted
class_name GridController

var size_x: int
var size_y: int
var size_z: int

var cells: BoolArray3D = []


func _init(p_size_x: int, p_size_y: int, p_size_z: int) -> void:
	size_x = p_size_x
	size_y = p_size_y
	size_z = p_size_z
	_allocate()


func _allocate() -> void:
	cells.clear()
	cells.resize(size_x)
	for x in range(size_x):
		cells[x] = []
		cells[x].resize(size_y)
		for y in range(size_y):
			cells[x][y] = []
			cells[x][y].resize(size_z)
			for z in range(size_z):
				cells[x][y][z] = false


func duplicate_empty() -> BoolArray3D:
	var next: Array[Array[Array[bool]]] = []
	next.resize(size_x)
	for x in range(size_x):
		next[x] = []
		next[x].resize(size_y)
		for y in range(size_y):
			next[x][y] = []
			next[x][y].resize(size_z)
			for z in range(size_z):
				next[x][y][z] = false
	return next


func randomize(density: float, rng: RandomNumberGenerator) -> void:
	for x in range(size_x):
		for y in range(size_y):
			for z in range(size_z):
				cells[x][y][z] = rng.randf() < density


func is_alive(x: int, y: int, z: int) -> bool:
	return cells[x][y][z]


func count_neighbors(x: int, y: int, z: int, wrap_edges: bool) -> int:
	var count := 0

	for dx in range(-1, 2):
		for dy in range(-1, 2):
			for dz in range(-1, 2):
				if dx == 0 and dy == 0 and dz == 0:
					continue

				var nx := x + dx
				var ny := y + dy
				var nz := z + dz

				if wrap_edges:
					nx = (nx + size_x) % size_x
					ny = (ny + size_y) % size_y
					nz = (nz + size_z) % size_z
					if cells[nx][ny][nz]:
						count += 1
				else:
					if nx < 0 or nx >= size_x:
						continue
					if ny < 0 or ny >= size_y:
						continue
					if nz < 0 or nz >= size_z:
						continue
					if cells[nx][ny][nz]:
						count += 1

	return count
