extends RefCounted
class_name EvolutionController

var grid: CA3DGrid
var rule: CA3DRule
var wrap_edges: bool = false


func _init(p_grid: CA3DGrid, p_rule: CA3DRule, p_wrap_edges: bool = false) -> void:
	grid = p_grid
	rule = p_rule
	wrap_edges = p_wrap_edges


func step() -> void:
	var next: Array[Array[Array[bool]]] = grid.duplicate_empty()

	for x in range(grid.size_x):
		for y in range(grid.size_y):
			for z in range(grid.size_z):
				var alive: bool = grid.cells[x][y][z]
				var neighbors: int = grid.count_neighbors(x, y, z, wrap_edges)
				next[x][y][z] = rule.get_next_state(alive, neighbors)

	grid.cells = next
