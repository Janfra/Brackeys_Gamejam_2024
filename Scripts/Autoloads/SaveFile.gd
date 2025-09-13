extends Node

const SAVE_PATH = "user://Saves/"
const LEVEL_DATA_RELATIVE_SAVE_PATH = "LevelsProgress/"
const SAVE_TYPE = ".save"

func save_level_data(levelData : LevelData) -> void:
	var save_dict: Dictionary = _generate_level_data_dictionary(levelData)
	if not _does_folder_exists(_get_level_data_folder_path()):
		return
	
	var save_file: FileAccess = FileAccess.open(_get_level_data_save_path(levelData), FileAccess.WRITE)
	if save_file == null:
		printerr("FileAccess Error, unable to open file. Error: ", error_string(FileAccess.get_open_error()))
		return
	
	var json_string: String = JSON.stringify(save_dict)
	
	save_file.store_line(json_string)
	# FileAccess closes file automatically once it goes out of scope

func load_level_data(levelData : LevelData) -> void:
	var levelDataSavePath: String = _get_level_data_save_path(levelData)
	if not FileAccess.file_exists(levelDataSavePath):
		return # Save file does not exists
	
	var save_file = FileAccess.open(levelDataSavePath, FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string: String = save_file.get_line()
		
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if parse_result != OK:
			printerr("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var resource_data = json.data
		
		levelData.has_been_completed = resource_data["hasBeenCompleted"]
		levelData.record_time = resource_data["recordTime"]
	

func _generate_level_data_dictionary(levelData : LevelData) -> Dictionary:
	var save_dict: Dictionary = {
		"fileUID": ResourceLoader.get_resource_uid(levelData.resource_path),
		"hasBeenCompleted": levelData.has_been_completed,
		"recordTime": levelData.record_time,
	}
	
	return save_dict

# Check if required save folder exists and create it if it does not
func _does_folder_exists(save_folder_path: String) -> bool:
	if not DirAccess.dir_exists_absolute(save_folder_path):
		var error_code: Error = DirAccess.make_dir_recursive_absolute(save_folder_path)
		if error_code != OK:
			printerr("FileAccess Error, unable to create directory. Error: ", error_string(error_code))
			return false
	return true
	

func _get_level_data_folder_path() -> String:
	return str(SAVE_PATH, LEVEL_DATA_RELATIVE_SAVE_PATH)

func _get_level_data_save_path(levelData : LevelData) -> String:
	return str(_get_level_data_folder_path(), ResourceLoader.get_resource_uid(levelData.resource_path), SAVE_TYPE)
