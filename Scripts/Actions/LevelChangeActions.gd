class_name LevelChangeActions
extends Node

## Intended to be used with buttons when changing levels to execute an action

@export_category("Config")
@export
var load_level: LevelData

func on_level_skip() -> void:
	GameTimer.timer_completed()
	GameManager.level_skip(load_level)
	

func on_level_load() -> void:
	GameManager.load_next_level(load_level)
	
