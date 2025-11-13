extends Node3D

@export var cells_per_side: int = 10
@export var cells_y: int = 5
@export var cell_size: float = 1.0
@export var base_y: float = 0.0

@export var cube_scene: PackedScene
@export var rule: IRule       

@export var step_interval: float = 0.25
@export var auto_run: bool = true
@export var initial_alive_chance: float = 0.25
@export var wrap_edges: bool = false

var rng := RandomNumberGenerator.new()
var grid: GridController
var automaton: EvolutionController
var volume_renderer: CellRenderer
var bounds_renderer: BoundaryRenderer

var time_accum: float = 0.0


func _ready() -> void:
	rng.randomize()

	# Estado
	grid = GridController.new(cells_per_side, cells_y, cells_per_side)
	grid.randomize(initial_alive_chance, rng)

	# Regra default se nada foi atribuído
	if rule == null:
		rule = ConwaysRule.new()

	# Autômato
	automaton = EvolutionController.new(grid, rule, wrap_edges)

	# Bounds
	bounds_renderer = BoundaryRenderer.new()
	add_child(bounds_renderer)
	bounds_renderer.build_bounds(cells_per_side, cells_y, cell_size, base_y)

	# Renderer de células
	volume_renderer = CellRenderer.new()
	add_child(volume_renderer)
	volume_renderer.setup(cube_scene, cell_size, base_y)
	volume_renderer.build_from_grid(grid)


func _process(delta: float) -> void:
	if not auto_run:
		return
	
	_handle_input()
		
	time_accum += delta
	if time_accum >= step_interval:
		time_accum = 0.0
		_step_and_render()

func _handle_input() -> void:
	if Input.is_action_just_pressed("start"):
		grid.randomize(initial_alive_chance, rng)
		volume_renderer.update_from_grid(grid)
		
	elif Input.is_action_just_pressed("skip"):
		_step_and_render()

func _step_and_render() -> void:
	automaton.step()
	volume_renderer.update_from_grid(grid)
