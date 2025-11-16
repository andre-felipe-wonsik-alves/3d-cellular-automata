class_name GeneConfig

const MIN_GENE: int = 0
const MAX_GENE: int = 5
const NO_GENE: int = -1

static func clamp(gene: int) -> int:
	return clampi(gene, MIN_GENE, MAX_GENE)

static func span() -> int:
	return max(1, MAX_GENE - MIN_GENE)

static func random_gene(rng: RandomNumberGenerator) -> int:
	return rng.randi_range(MIN_GENE, MAX_GENE)

static func distance_to_target(gene: int, target_gene: int) -> int:
	return abs(gene - target_gene)
