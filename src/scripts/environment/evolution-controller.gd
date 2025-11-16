extends RefCounted
class_name EvolutionController

const GeneConfig = preload("res://scripts/environment/genetics/gene-config.gd")
const GeneGrid = preload("res://scripts/environment/genetics/gene-grid.gd")
const GeneRegulator = preload("res://scripts/environment/genetics/gene-regulator.gd")

var grid: GridController
var rule: IRule
var wrap_edges: bool = false
var gene_regulator: GeneRegulator
var rng: RandomNumberGenerator

func _init(p_grid: GridController, p_rule: IRule, p_wrap_edges: bool = false, p_gene_regulator: GeneRegulator = null, p_rng: RandomNumberGenerator = null) -> void:
	grid = p_grid
	rule = p_rule
	wrap_edges = p_wrap_edges
	gene_regulator = p_gene_regulator
	rng = p_rng if p_rng != null else RandomNumberGenerator.new()
	if p_rng == null:
		rng.randomize()

func step() -> void:
	var next_cells: BoolArray3D = grid.create_alive_buffer()
	var next_genes = grid.create_gene_buffer()

	for x in range(grid.size_x):
		for y in range(grid.size_y):
			for z in range(grid.size_z):
				var alive: bool = grid.get_cell(x, y, z)
				var neighbors = grid.analyze_neighbors(x, y, z, wrap_edges)
				var base_next_alive: bool = rule.get_next_state(alive, neighbors.alive_count)
				if alive:
					_process_survival(x, y, z, base_next_alive, next_cells, next_genes)
				else:
					_process_birth(x, y, z, base_next_alive, neighbors.get_alive_genes(), next_cells, next_genes)

	grid.apply_state(next_cells, next_genes)

func _process_survival(x: int, y: int, z: int, base_next_alive: bool, next_cells: BoolArray3D, next_genes: GeneGrid) -> void:
	if not base_next_alive:
		return
	var gene := grid.get_gene(x, y, z)
	if _passes_genetic_gate(gene):
		next_cells.set_at(x, y, z, true)
		next_genes.set_gene(x, y, z, gene)

func _process_birth(x: int, y: int, z: int, base_next_alive: bool, neighbor_genes: Array[int], next_cells: BoolArray3D, next_genes: GeneGrid) -> void:
	if not base_next_alive:
		return
	var new_gene := _determine_birth_gene(neighbor_genes)
	if new_gene == GeneConfig.NO_GENE:
		return
	next_cells.set_at(x, y, z, true)
	next_genes.set_gene(x, y, z, new_gene)

func _passes_genetic_gate(gene: int) -> bool:
	if gene_regulator == null:
		return true
	return gene_regulator.evaluate_survival(gene, rng)

func _determine_birth_gene(neighbor_genes: Array[int]) -> int:
	if neighbor_genes.is_empty():
		return GeneConfig.NO_GENE
	if gene_regulator == null:
		return neighbor_genes[0]
	return gene_regulator.evaluate_birth(neighbor_genes, rng)
