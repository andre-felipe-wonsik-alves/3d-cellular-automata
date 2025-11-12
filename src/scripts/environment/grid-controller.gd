extends RefCounted
class_name GridController

var size_x: int
var size_y: int
var size_z: int

# antes: var cells: BoolArray3D = []
var cells: BoolArray3D = BoolArray3D.new()

func _init(p_size_x: int, p_size_y: int, p_size_z: int) -> void:
	size_x = p_size_x
	size_y = p_size_y
	size_z = p_size_z
	_allocate()

func randomize(density: float, rng: RandomNumberGenerator) -> void:
	for x: int in range(size_x):
		for y: int in range(size_y):
			for z: int in range(size_z):
				var alive: bool = rng.randf() < density
				cells.set_at(x, y, z, alive)


func _allocate() -> void:
	# antes: clear/resize com Array; agora criamos a estrutura já pronta
	cells = BoolArray3D.new(size_x, size_y, size_z, false)

func set_cell(x: int, y: int, z: int, alive: bool) -> void:
	cells.set_at(x, y, z, alive)

func get_cell(x: int, y: int, z: int) -> bool:
	return cells.get_at(x, y, z)

func step(wrap: bool = false) -> void:
	var next := BoolArray3D.new(size_x, size_y, size_z, false)

	for z in range(size_z):
		for y in range(size_y):
			for x in range(size_x):
				var alive := cells.get_at(x, y, z)
				var n := _count_neighbors(x, y, z, wrap)
				var will_live := false
				if alive:
					will_live = (n == 2 or n == 3)
				else:
					will_live = (n == 3)
				next.set_at(x, y, z, will_live)

	cells = next

func _count_neighbors(x: int, y: int, z: int, wrap: bool) -> int:
	var count := 0
	for dz in range(-1,2):
		for dy in range(-1,2):
			for dx in range(-1,2):
				if dx == 0 and dy == 0 and dz == 0:
					continue
				var nx := x + dx
				var ny := y + dy
				var nz := z + dz
				if wrap:
					nx = (nx + size_x) % size_x
					ny = (ny + size_y) % size_y
					nz = (nz + size_z) % size_z
					if cells.get_at(nx, ny, nz):
						count += 1
				else:
					if nx < 0 or nx >= size_x: continue
					if ny < 0 or ny >= size_y: continue
					if nz < 0 or nz >= size_z: continue
					if cells.get_at(nx, ny, nz):
						count += 1
	return count

func duplicate_empty() -> BoolArray3D:
	return BoolArray3D.new(size_x, size_y, size_z)
