extends Node3D

@export var cells_per_side: int = 10
@export var cells_y: int = 5
@export var cell_size: float = 1.0
@export var base_y: float = 0.0

@export var cube_scene: PackedScene
@export var rule: IRule        # arraste um BasicLife3DRule no editor

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
	grid = CA3DGrid.new(cells_per_side, cells_y, cells_per_side)
	grid.randomize(initial_alive_chance, rng)

	# Regra default se nada foi atribuído
	if rule == null:
		rule = BasicLife3DRule.new()

	# Autômato
	automaton = CA3DAutomaton.new(grid, rule, wrap_edges)

	# Bounds
	bounds_renderer = BoundsRenderer3D.new()
	add_child(bounds_renderer)
	bounds_renderer.build_bounds(cells_per_side, cells_y, cell_size, base_y)

	# Renderer de células
	volume_renderer = VolumeRenderer3D.new()
	add_child(volume_renderer)
	volume_renderer.setup(cube_scene, cell_size, base_y)
	volume_renderer.build_from_grid(grid)


func _process(delta: float) -> void:
	if not auto_run:
		return

	time_accum += delta
	if time_accum >= step_interval:
		time_accum = 0.0
		_step_and_render()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_step_and_render()
	elif event.is_action_pressed("ui_select"):
		grid.randomize(initial_alive_chance, rng)
		volume_renderer.update_from_grid(grid)


func _step_and_render() -> void:
	automaton.step()
	volume_renderer.update_from_grid(grid)
