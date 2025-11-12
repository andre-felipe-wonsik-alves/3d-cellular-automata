extends IRule
class_name ConwaysRule

@export var birth_min: int = 5
@export var birth_max: int = 5
@export var survive_min: int = 4
@export var survive_max: int = 5

func get_next_state(current_alive: bool, neighbors: int) -> bool:
	if current_alive:
		return neighbors >= survive_min and neighbors <= survive_max
	else:
		return neighbors >= birth_min and neighbors <= birth_max
