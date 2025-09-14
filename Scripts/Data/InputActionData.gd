@tool
class_name InputActionData
extends Resource

@export 
var action_name: StringName

@export
var keycodes: Array[Key] : get = _get_keycodes
var _cache_keycodes: Array[Key]

@export_tool_button("Verify Name And Get Keycodes")
var _has_input = _verify_input_name

func _get_keycodes() -> Array[Key]:
	if _cache_keycodes == null:
		return []
	else:
		return _cache_keycodes

func _verify_input_name() -> void:
	_cache_keycodes.clear()
	var input_setting_name = str("input/", action_name)
	if not ProjectSettings.has_setting(input_setting_name):
		printerr("Unable to find action: {} in project settings. Please verify that name matches name in Input Map".format([input_setting_name], "{}"))
	else:
		var input_dictionary: Dictionary = ProjectSettings.get_setting(input_setting_name)
		if input_dictionary:
			_set_keycodes_from_settings_dictionary(input_dictionary)

func _set_keycodes_from_settings_dictionary(input_dictionary: Dictionary) -> void:
	for inputEvent in input_dictionary["events"]:
		if inputEvent is InputEventKey:
			if inputEvent.keycode == 0:
				_cache_keycodes.append(inputEvent.physical_keycode as Key)
			else:
				_cache_keycodes.append(inputEvent.keycode as Key)
	
