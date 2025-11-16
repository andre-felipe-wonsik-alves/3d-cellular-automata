extends RefCounted
class_name GridController

const GeneConfig = preload("res://scripts/environment/genetics/gene-config.gd")
const GeneGrid = preload("res://scripts/environment/genetics/gene-grid.gd")
const NeighborhoodSnapshot = preload("res://scripts/environment/abstract/grid/neighborhood-snapshot.gd")

var size_x: int
var size_y: int
var size_z: int

var cells: BoolArray3D = BoolArray3D.new()
var genes: GeneGrid = GeneGrid.new()

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
				if alive:
					genes.set_gene(x, y, z, GeneConfig.random_gene(rng))
				else:
					genes.set_gene(x, y, z, GeneConfig.NO_GENE)

func _allocate() -> void:
	cells = BoolArray3D.new(size_x, size_y, size_z, false)
	genes = GeneGrid.new(size_x, size_y, size_z, GeneConfig.NO_GENE)

func set_cell(x: int, y: int, z: int, alive: bool) -> void:
	cells.set_at(x, y, z, alive)
	if not alive:
		genes.set_gene(x, y, z, GeneConfig.NO_GENE)

func get_cell(x: int, y: int, z: int) -> bool:
	return cells.get_at(x, y, z)

func set_gene(x: int, y: int, z: int, gene: int) -> void:
	genes.set_gene(x, y, z, GeneConfig.clamp(gene))

func get_gene(x: int, y: int, z: int) -> int:
	return genes.get_gene(x, y, z)

func step(wrap: bool = false) -> void:
	var next := BoolArray3D.new(size_x, size_y, size_z, false)
	var next_genes := GeneGrid.new(size_x, size_y, size_z, GeneConfig.NO_GENE)

	for z in range(size_z):
		for y in range(size_y):
			for x in range(size_x):
				var alive := cells.get_at(x, y, z)
				var n := count_neighbors(x, y, z, wrap)
				var will_live := false
				if alive:
					will_live = (n == 2 or n == 3)
				else:
					will_live = (n == 3)
				if will_live:
					next.set_at(x, y, z, true)
					next_genes.set_gene(x, y, z, genes.get_gene(x, y, z))
				else:
					next.set_at(x, y, z, false)
					next_genes.set_gene(x, y, z, GeneConfig.NO_GENE)

	cells = next
	genes = next_genes

func count_neighbors(x: int, y: int, z: int, wrap: bool) -> int:
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

func analyze_neighbors(x: int, y: int, z: int, wrap: bool) -> NeighborhoodSnapshot:
	var snapshot := NeighborhoodSnapshot.new()
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
				else:
					if nx < 0 or nx >= size_x: continue
					if ny < 0 or ny >= size_y: continue
					if nz < 0 or nz >= size_z: continue
				if cells.get_at(nx, ny, nz):
					snapshot.record_alive(genes.get_gene(nx, ny, nz))
	return snapshot

func create_alive_buffer(default_value: bool = false) -> BoolArray3D:
	return BoolArray3D.new(size_x, size_y, size_z, default_value)

func create_gene_buffer(default_gene: int = GeneConfig.NO_GENE) -> GeneGrid:
	return GeneGrid.new(size_x, size_y, size_z, default_gene)

func apply_state(next_cells: BoolArray3D, next_genes: GeneGrid) -> void:
	cells = next_cells
	genes = next_genes
