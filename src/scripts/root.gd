extends Node3D

const CUBE = preload("uid://fl1rsvgyxi4d")

func _process(delta:float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		print("Criando um cubo")
		var cubo = CUBE.instantiate();
		add_child(cubo);
	
