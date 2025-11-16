extends Node3D
class_name CellView

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
var material: StandardMaterial3D = StandardMaterial3D.new()

func _ready() -> void:
	mesh_instance.material_override = material

func set_cell_color(color: Color) -> void:
	material.albedo_color = color
