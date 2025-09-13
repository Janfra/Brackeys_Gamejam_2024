extends Node

## Aids with saving configurations and loading configurations

func print_actions() -> void:
	var actions: Array[StringName] = InputMap.get_actions()
	print(actions)
	
