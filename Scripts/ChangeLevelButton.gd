class_name ChangeLevelButton
extends Button

@export_category("Config")
@export
var load_level: LevelData

func _on_pressed():
	GameTimer.timer_completed()
	GameManager.level_skip(load_level)
	
