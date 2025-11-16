extends RefCounted
class_name GeneRegulator

const GeneConfig = preload("res://scripts/environment/genetics/gene-config.gd")

var target_gene: int
var mutation_chance: float

func _init(p_target_gene: int, p_mutation_chance: float) -> void:
	target_gene = GeneConfig.clamp(p_target_gene)
	mutation_chance = clampf(p_mutation_chance, 0.0, 1.0)

func evaluate_survival(gene: int, rng: RandomNumberGenerator) -> bool:
	if gene == GeneConfig.NO_GENE:
		return false
	return rng.randf() <= _fitness(gene)

func evaluate_birth(neighbor_genes: Array[int], rng: RandomNumberGenerator) -> int:
	if neighbor_genes.is_empty():
		return GeneConfig.NO_GENE
	var inherited_gene := _inherit_gene(neighbor_genes, rng)
	var final_gene := _maybe_mutate(inherited_gene, rng)
	return final_gene if rng.randf() <= _fitness(final_gene) else GeneConfig.NO_GENE

func _inherit_gene(neighbor_genes: Array[int], rng: RandomNumberGenerator) -> int:
	var index := rng.randi_range(0, neighbor_genes.size() - 1)
	return neighbor_genes[index]

func _maybe_mutate(gene: int, rng: RandomNumberGenerator) -> int:
	if rng.randf() < mutation_chance:
		return GeneConfig.random_gene(rng)
	return gene

func _fitness(gene: int) -> float:
	var distance := GeneConfig.distance_to_target(gene, target_gene)
	var span := float(GeneConfig.span())
	return clampf(1.0 - (float(distance) / span), 0.0, 1.0)
