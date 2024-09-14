extends Button

@export_category("Config")
@export
var load_level: LevelData

func _on_pressed():
	GameManager.load_next_level(load_level)
	
