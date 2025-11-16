extends RefCounted
class_name NeighborhoodSnapshot

var alive_count: int = 0
var alive_genes: Array[int] = []

func record_alive(gene: int) -> void:
	alive_count += 1
	alive_genes.append(gene)

func get_alive_genes() -> Array[int]:
	return alive_genes
