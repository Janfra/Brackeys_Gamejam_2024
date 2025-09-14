@tool
class_name InputActionData
extends Resource

@export 
var action_name: StringName

@export
var keycodes: Array[Key] : get = _get_keycodes
var _cache_keycodes: Array[Key]

@export_tool_button("Verify Name And Get Keycodes")
var __Editor_has_input = __Editor_verify_input_name

func on_action_events_rebinded() -> void:
	var events: Array[InputEvent] = InputMap.action_get_events(action_name)
	_set_cached_keycodes_with_input_events(events)
	

func _set_cached_keycodes_with_input_events(events: Array[InputEvent]) -> void:
	_cache_keycodes.clear()
	for event in events:
		if event is InputEventKey:
			if event.keycode == 0:
				_cache_keycodes.append(event.physical_keycode as Key)
			else:
				_cache_keycodes.append(event.keycode as Key)
		

func _get_keycodes() -> Array[Key]:
	if _cache_keycodes == null:
		return []
	else:
		return _cache_keycodes

func __Editor_verify_input_name() -> void:
	if not Engine.is_editor_hint():
		return
	
	_cache_keycodes.clear()
	var input_setting_name = str("input/", action_name)
	if not ProjectSettings.has_setting(input_setting_name):
		printerr("Unable to find action: {} in project settings. Please verify that name matches name in Input Map".format([input_setting_name], "{}"))
	else:
		var input_dictionary: Dictionary = ProjectSettings.get_setting(input_setting_name)
		if input_dictionary:
			__Editor_set_keycodes_from_settings_dictionary(input_dictionary)
			print("{action_name} project settings found!".format(self))

func __Editor_set_keycodes_from_settings_dictionary(input_dictionary: Dictionary) -> void:
	if not Engine.is_editor_hint():
		return
	
	var events: Array[InputEvent] = Array(input_dictionary["events"], TYPE_OBJECT, "InputEvent", null)
	_set_cached_keycodes_with_input_events(events)
	
