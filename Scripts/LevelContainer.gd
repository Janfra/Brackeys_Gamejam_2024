class_name LevelContainer
extends Node2D

const SAVE_PATH = "user://Saves/"

@export_category("Config")
@export
var level_data: LevelData
@export
var next_level_data: LevelData

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(level_data)
	if level_data.is_valid():
		GameManager.set_level_data(level_data)
	else:
		return
	
	GameTimer.set_level_record_time(level_data.record_time)
	GameTimer.new_record.connect(_update_best_time.bind())
	GameManager.level_completed.connect(_update_completion.bind())
	

func _update_best_time(time : float) -> void:
	level_data.record_time = time
	

func _update_completion() -> void:
	level_data.has_been_completed = true
	GameManager.load_next_level(next_level_data)
	
