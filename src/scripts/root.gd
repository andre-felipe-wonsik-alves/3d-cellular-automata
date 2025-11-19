extends Node3D

@export var cells_x: int = 10
@export var cells_y: int = 5
@export var cell_size: float = 1.0
@export var base_y: float = 0.0

const GeneConfig = preload("res://scripts/environment/genetics/gene-config.gd")
const GeneRegulator = preload("res://scripts/environment/genetics/gene-regulator.gd")

@export var cube_scene: PackedScene
@export var rule: IRule       

@export var step_interval: float = 0.25
@export var auto_run: bool = true
@export var initial_alive_chance: float = 0.25
@export var wrap_edges: bool = false
@export_range(0.0, 1.0, 0.01) var mutation_chance: float = 0.1
@export_range(0, 5, 1) var target_gene: int = 3 

var rng := RandomNumberGenerator.new()
var grid: GridController
var automaton: EvolutionController
var volume_renderer: CellRenderer
var bounds_renderer: BoundaryRenderer
var gene_regulator: GeneRegulator

var time_accum: float = 0.0
var generation_count: int = 0

@onready var generation_label: Label = $UI/GenerationLabel


func _ready() -> void:
	rng.randomize()

	# Estado
	grid = GridController.new(cells_x, cells_y, cells_x)
	grid.randomize(initial_alive_chance, rng)

	if rule == null:
		rule = ConwaysRule.new()
	_create_gene_regulator()

	# Autômato
	automaton = EvolutionController.new(grid, rule, wrap_edges, gene_regulator, rng)

	# Bounds
	#bounds_renderer = BoundaryRenderer.new()
	#add_child(bounds_renderer)
	#bounds_renderer.build_bounds(cells_x, cells_y, cell_size, base_y)

	# Renderer de células
	volume_renderer = CellRenderer.new()
	add_child(volume_renderer)
	volume_renderer.setup(cube_scene, cell_size, base_y)
	volume_renderer.build_from_grid(grid)
	_update_generation_label()


func _process(delta: float) -> void:
	if not auto_run:
		_handle_input()
		
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
		generation_count = 0
		_update_generation_label()
		
	elif Input.is_action_just_pressed("skip"):
		_step_and_render()

func _step_and_render() -> void:
	automaton.step()
	if !grid.is_empty():
		generation_count += 1
	_update_generation_label()
	volume_renderer.update_from_grid(grid)

func set_mutation_chance(value: float) -> void:
	mutation_chance = clampf(value, 0.0, 1.0)
	if gene_regulator:
		gene_regulator.mutation_chance = mutation_chance

func set_target_gene(value: int) -> void:
	target_gene = clampi(value, GeneConfig.MIN_GENE, GeneConfig.MAX_GENE)
	if gene_regulator:
		gene_regulator.target_gene = target_gene

func _create_gene_regulator() -> void:
	gene_regulator = GeneRegulator.new(target_gene, mutation_chance)

func _update_generation_label() -> void:
	if generation_label:
		generation_label.text = "Gerações: %d" % generation_count
