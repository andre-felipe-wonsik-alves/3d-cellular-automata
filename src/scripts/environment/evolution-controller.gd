extends RefCounted
class_name EvolutionController

var grid: GridController
var rule: ConwaysRule
var wrap_edges: bool = false

func _init(p_grid: GridController, p_rule: ConwaysRule, p_wrap_edges: bool = false) -> void:
	grid = p_grid
	rule = p_rule
	wrap_edges = p_wrap_edges

func step() -> void:
	var next: BoolArray3D = grid.duplicate_empty()

	for x in range(grid.size_x):
		for y in range(grid.size_y):
			for z in range(grid.size_z):
				var alive: bool = grid.cells.get_at(x, y, z)
				var neighbors: int = grid._count_neighbors(x, y, z, wrap_edges)
				next.set_at(x, y, z, rule.get_next_state(alive, neighbors))

	grid.cells = next
