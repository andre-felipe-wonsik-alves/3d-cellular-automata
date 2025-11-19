extends Node3D
class_name BoundaryRenderer

@export var floor_color: Color = Color(0.2, 0.6, 1.0, 0.25)
@export var depth_wall_color: Color = Color(1.0, 0.5, 0.2, 0.25)
@export var width_wall_color: Color = Color(0.2, 1.0, 0.4, 0.25)


func build_bounds(size_x: int, size_y: int, cell_size: float, base_y: float) -> void:
	for child in get_children():
		child.queue_free()

	var width_size := float(size_x) * cell_size
	var depth_size := float(size_x) * cell_size
	var height_size := float(size_y) * cell_size
	var half_width := width_size * 0.5
	var half_depth := depth_size * 0.5
	var center_y := base_y + height_size * 0.5
	var eps := 0.01

	# Chão (XZ)
	_create_plane(
		Vector2(width_size, depth_size),
		floor_color,
		Vector3(-90.0, 0.0, 0.0),
		Vector3(0.0, base_y - eps, 0.0)
	)

	# Paredes XY (Z- e Z+)
	_create_plane(
		Vector2(width_size, height_size),
		depth_wall_color,
		Vector3.ZERO,
		Vector3(0.0, center_y, half_depth + eps)
	)
	_create_plane(
		Vector2(width_size, height_size),
		depth_wall_color,
		Vector3(0.0, 180.0, 0.0),
		Vector3(0.0, center_y, -half_depth - eps)
	)

	# Paredes YZ (X- e X+)
	_create_plane(
		Vector2(depth_size, height_size),
		width_wall_color,
		Vector3(0.0, -90.0, 0.0),
		Vector3(half_width + eps, center_y, 0.0)
	)
	_create_plane(
		Vector2(depth_size, height_size),
		width_wall_color,
		Vector3(0.0, 90.0, 0.0),
		Vector3(-half_width - eps, center_y, 0.0)
	)


func _create_plane(size: Vector2, color: Color, rotation: Vector3, position: Vector3) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = size
	mesh_instance.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = mat

	mesh_instance.rotation_degrees = rotation
	mesh_instance.position = position
	add_child(mesh_instance)
