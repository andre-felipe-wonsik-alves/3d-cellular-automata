extends RefCounted
class_name GeneGrid

const GeneConfig = preload("res://scripts/environment/genetics/gene-config.gd")

var width: int
var height: int
var depth: int
var layers: Array = []

func _init(p_width: int = 0, p_height: int = 0, p_depth: int = 0, default_gene: int = GeneConfig.NO_GENE) -> void:
	width = p_width
	height = p_height
	depth = p_depth
	layers.resize(depth)
	for z in range(depth):
		layers[z] = []
		layers[z].resize(height)
		for y in range(height):
			var row := PackedInt32Array()
			row.resize(width)
			for x in range(width):
				row[x] = default_gene
			layers[z][y] = row

func set_gene(x: int, y: int, z: int, gene: int) -> void:
	if _is_out_of_bounds(x, y, z):
		return
	layers[z][y][x] = gene

func get_gene(x: int, y: int, z: int) -> int:
	if _is_out_of_bounds(x, y, z):
		return GeneConfig.NO_GENE
	return layers[z][y][x]

func duplicate() -> GeneGrid:
	var copy := GeneGrid.new(width, height, depth, GeneConfig.NO_GENE)
	for z in range(depth):
		for y in range(height):
			var row: PackedInt32Array = layers[z][y]
			for x in range(width):
				copy.set_gene(x, y, z, row[x])
	return copy

func fill(gene: int) -> void:
	for z in range(depth):
		for y in range(height):
			var row: PackedInt32Array = layers[z][y]
			for x in range(width):
				row[x] = gene

func _is_out_of_bounds(x: int, y: int, z: int) -> bool:
	return x < 0 or x >= width or y < 0 or y >= height or z < 0 or z >= depth
