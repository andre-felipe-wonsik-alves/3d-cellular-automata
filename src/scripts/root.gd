extends Node3D

const CUBE = preload("uid://fl1rsvgyxi4d") # Cena do cubo

@export var cells_per_side: int = 10      # Células em X e Z
@export var cells_y: int = 5              # Células em Y (altura)
@export var cell_size: float = 1.0        # Tamanho de cada célula
@export var base_y: float = 0.0           # Altura do "piso"

@export var floor_color: Color = Color(0.2, 0.6, 1.0, 0.25)      # chão (XZ)
@export var wall_color: Color = Color(1.0, 0.5, 0.2, 0.25)       # parede fundo (XY)
@export var left_wall_color: Color = Color(0.2, 1.0, 0.4, 0.25)  # parede esquerda (YZ)

@export_category("CA - Regras e Execução")
@export var step_interval: float = 0.25            # tempo entre steps (se auto_run = true)
@export_range(0.0, 1.0, 0.01)
var initial_alive_chance: float = 0.25             # densidade inicial

@export var birth_min: int = 5
@export var birth_max: int = 5
@export var survive_min: int = 4
@export var survive_max: int = 5

@export var wrap_edges: bool = false               # borda com wrap ou limites duros
@export var auto_run: bool = true                  # roda sozinho no _process

var rng := RandomNumberGenerator.new()

# grid[x][y][z] = bool (estado atual)
var grid: Array = []
var next_grid: Array = []

# Mapa posição discreta -> instância do cubo
var cubes: Dictionary[Vector3i, Node3D] = {}

var time_accum: float = 0.0


func _ready() -> void:
	rng.randomize()
	_create_bounds()
	_create_cells()
	randomize_grid()


func _process(delta: float) -> void:
	if not auto_run:
		return

	time_accum += delta
	if time_accum >= step_interval:
		time_accum = 0.0
		step_automaton()


func _unhandled_input(event: InputEvent) -> void:
	# Espaço: um passo manual
	if event.is_action_pressed("ui_accept"):
		step_automaton()
	# Enter (ou o que você mapear em "ui_select"): randomiza o grid
	if event.is_action_pressed("ui_select"):
		randomize_grid()

func _create_cells() -> void:
	grid.clear()
	next_grid.clear()
	cubes.clear()

	grid.resize(cells_per_side)
	next_grid.resize(cells_per_side)

	for x in range(cells_per_side):
		grid[x] = []
		next_grid[x] = []
		for y in range(cells_y):
			grid[x].append([])
			next_grid[x].append([])
			for z in range(cells_per_side):
				grid[x][y].append(false)
				next_grid[x][y].append(false)

				var cube: Node3D = CUBE.instantiate()
				cube.position = cell_to_world_pos(x, y, z)
				add_child(cube)

				var key := Vector3i(x, y, z)
				cubes[key] = cube


func _create_bounds() -> void:
	var side_size := float(cells_per_side) * cell_size
	var height_size := float(cells_y) * cell_size
	var half := side_size * 0.5
	var eps := 0.01

	# Chão (plano XZ)
	var floor := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(side_size, side_size)
	floor.mesh = floor_mesh

	var floor_mat := StandardMaterial3D.new()
	floor_mat.albedo_color = floor_color
	floor_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	floor_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	floor_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	floor.material_override = floor_mat

	floor.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	floor.position = Vector3(0.0, base_y - eps, 0.0)
	add_child(floor)

	# Parede de fundo (XY) em Z+
	var back_wall := MeshInstance3D.new()
	var back_mesh := PlaneMesh.new()
	back_mesh.size = Vector2(side_size, height_size)
	back_wall.mesh = back_mesh

	var back_mat := StandardMaterial3D.new()
	back_mat.albedo_color = wall_color
	back_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	back_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	back_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	back_wall.material_override = back_mat

	back_wall.position = Vector3(0.0, base_y + height_size * 0.5, half + eps)
	add_child(back_wall)

	# Parede esquerda (YZ) em X-
	var left_wall := MeshInstance3D.new()
	var left_mesh := PlaneMesh.new()
	left_mesh.size = Vector2(height_size, side_size)
	left_wall.mesh = left_mesh

	var left_mat := StandardMaterial3D.new()
	left_mat.albedo_color = left_wall_color
	left_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	left_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	left_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	left_wall.material_override = left_mat

	# Plane padrão é XZ; rotacionamos para YZ
	left_wall.rotation_degrees = Vector3(0.0, 0.0, -90.0)
	left_wall.position = Vector3(-half - eps, base_y + height_size * 0.5, 0.0)
	add_child(left_wall)


# =========================
#  Conversão de coordenadas
# =========================

func cell_to_world_pos(x: int, y: int, z: int) -> Vector3:
	var offset_x := (x - (cells_per_side / 2.0) + 0.5) * cell_size
	var offset_y := base_y + (y + 0.5) * cell_size
	var offset_z := (z - (cells_per_side / 2.0) + 0.5) * cell_size
	return Vector3(offset_x, offset_y, offset_z)


# =========================
#  Lógica da Cellular Automata
# =========================

func randomize_grid() -> void:
	for x in range(cells_per_side):
		for y in range(cells_y):
			for z in range(cells_per_side):
				var alive := rng.randf() < initial_alive_chance
				grid[x][y][z] = alive
				_apply_cell_visual(x, y, z, alive)


func step_automaton() -> void:
	# Calcula próxima geração
	for x in range(cells_per_side):
		for y in range(cells_y):
			for z in range(cells_per_side):
				var alive: bool = grid[x][y][z]
				var neighbors: int = count_neighbors(x, y, z)

				var next_alive := false
				if alive:
					if neighbors >= survive_min and neighbors <= survive_max:
						next_alive = true
				else:
					if neighbors >= birth_min and neighbors <= birth_max:
						next_alive = true

				next_grid[x][y][z] = next_alive

	# Aplica resultado e atualiza visual
	for x in range(cells_per_side):
		for y in range(cells_y):
			for z in range(cells_per_side):
				var alive : bool= next_grid[x][y][z]
				grid[x][y][z] = alive
				_apply_cell_visual(x, y, z, alive)


func count_neighbors(x: int, y: int, z: int) -> int:
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
					nx = (nx + cells_per_side) % cells_per_side
					ny = (ny + cells_y) % cells_y
					nz = (nz + cells_per_side) % cells_per_side
					if grid[nx][ny][nz]:
						count += 1
				else:
					if nx < 0 or nx >= cells_per_side:
						continue
					if ny < 0 or ny >= cells_y:
						continue
					if nz < 0 or nz >= cells_per_side:
						continue
					if grid[nx][ny][nz]:
						count += 1

	return count


func _apply_cell_visual(x: int, y: int, z: int, alive: bool) -> void:
	var key := Vector3i(x, y, z)
	var cube := cubes.get(key) as Node3D
	if cube == null:
		return

	cube.visible = alive
