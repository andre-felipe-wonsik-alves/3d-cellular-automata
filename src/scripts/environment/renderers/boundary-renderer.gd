extends Node3D
class_name BoundaryRenderer

@export var floor_color: Color = Color(0.2, 0.6, 1.0, 0.25)
@export var back_wall_color: Color = Color(1.0, 0.5, 0.2, 0.25)
@export var left_wall_color: Color = Color(0.2, 1.0, 0.4, 0.25)


func build_bounds(size_x: int, size_y: int, cell_size: float, base_y: float) -> void:
	for child in get_children():
		child.queue_free()

	var side_size := float(size_x) * cell_size
	var height_size := float(size_y) * cell_size
	var half := side_size * 0.5
	var eps := 0.01

	# Chão (XZ)
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

	# Parede fundo (XY) em Z+
	var back_wall := MeshInstance3D.new()
	var back_mesh := PlaneMesh.new()
	back_mesh.size = Vector2(side_size, height_size)
	back_wall.mesh = back_mesh

	var back_mat := StandardMaterial3D.new()
	back_mat.albedo_color = back_wall_color
	back_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	back_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	back_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	back_wall.material_override = back_mat

	back_wall.position = Vector3(0.0, base_y + height_size * 0.5, half + eps)
	add_child(back_wall)

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

	left_wall.rotation_degrees = Vector3(0.0, 0.0, -90.0)
	left_wall.position = Vector3(-half - eps, base_y + height_size * 0.5, 0.0)
	add_child(left_wall)
