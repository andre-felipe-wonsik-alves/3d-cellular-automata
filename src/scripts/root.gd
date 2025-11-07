extends Node3D

const CUBE = preload("uid://fl1rsvgyxi4d")

@export var cells_per_side: int = 10      # Quantidade de células por lado (ex: 10x10)
@export var cell_size: float = 1.0        # Tamanho de cada célula (deixe igual ao tamanho do cubo)
@export var spawn_height: float = 0.5     # Altura em Y onde o cubo será instanciado

var rng := RandomNumberGenerator.new()
var occupied_cells: = {}  # Armazena quais células já estão ocupadas (chave: Vector2i)

func _ready() -> void:
	rng.randomize()
	_create_area_visual()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		spawn_cube()

func spawn_cube() -> void:
	var total_cells := cells_per_side * cells_per_side
	if occupied_cells.size() >= total_cells:
		print("Nenhuma célula livre disponível.")
		return

	var cell := Vector2i.ZERO

	# Sorteia até achar uma célula vazia
	while true:
		var x_index = rng.randi_range(0, cells_per_side - 1)
		var z_index = rng.randi_range(0, cells_per_side - 1)
		cell = Vector2i(x_index, z_index)
		if not occupied_cells.has(cell):
			break

	# Marca célula como ocupada
	occupied_cells[cell] = true

	# Converte o índice da célula para posição no mundo (grid centralizada)
	var area_size = cells_per_side * cell_size
	var half = area_size * 0.5

	var world_x = -half + cell_size * 0.5 + float(cell.x) * cell_size
	var world_z = -half + cell_size * 0.5 + float(cell.y) * cell_size

	var cubo = CUBE.instantiate()
	cubo.position = Vector3(world_x, spawn_height, world_z)
	add_child(cubo)

func _create_area_visual() -> void:
	var area_size = cells_per_side * cell_size

	var plane := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(area_size, area_size)
	plane.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.6, 1.0, 0.25) # Azul clarinho semi-transparente
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	plane.material_override = mat

	# Centralizado na origem, levemente abaixo da altura de spawn
	plane.position = Vector3(0.0, spawn_height - 0.01, 0.0)

	add_child(plane)
