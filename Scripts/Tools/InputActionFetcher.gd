@tool
class_name InputActionFetcher
extends Resource

@warning_ignore("unused_private_class_variable")
@export_tool_button("Verify Name And Get Keycodes")
var __Editor_has_input = __Editor_verify_input_actions

@export
var _target_actions: Array[InputActionData]

func __Editor_verify_input_actions() -> void:
	if not Engine.is_editor_hint():
		return
	
	if not _target_actions or _target_actions.is_empty():
		printerr("Must provide a target actions before attempting to verify")
		return
	
	for action in _target_actions:
		__Editor_verify_and_set_inputs_for_action(action)
		

func __Editor_verify_and_set_inputs_for_action(action_data: InputActionData) -> void:
	if not Engine.is_editor_hint():
		return
	
	action_data._cache_keycodes.clear()
	var input_setting_name = str("input/", action_data.action_name)
	if not ProjectSettings.has_setting(input_setting_name):
		printerr("Unable to find action: {} in project settings. Please verify that name matches name in Input Map".format([input_setting_name], "{}"))
	else:
		var input_dictionary: Dictionary = ProjectSettings.get_setting(input_setting_name)
		if input_dictionary:
			__Editor_set_keycodes_from_settings_dictionary(action_data, input_dictionary)
			print("{action_name} project settings found!".format(self))
	

func __Editor_set_keycodes_from_settings_dictionary(action_data: InputActionData, input_dictionary: Dictionary) -> void:
	if not Engine.is_editor_hint():
		return
	
	var events: Array[InputEvent] = Array(input_dictionary["events"], TYPE_OBJECT, "InputEvent", null)
	action_data._set_cached_keycodes_with_input_events(events)
	
