class_name LevelData
extends Resource

@export_category("Dependencies")
@export_file("*.tscn")
var level: String
@export_category("Data")
@export
var record_time: float = 0.0
@export
var has_been_completed: bool = false

func is_valid() -> bool:
	var has_level = level.is_absolute_path()
	assert(has_level)
	return has_level
	
