class_name InputSettingsActions
extends Node

@export
var _action_data: InputActionData
var _requested_key: Key = KEY_NONE

signal requested_key_set(requested_key: Key)

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		assert(_action_data, "{name} has null references.".format(self))
		
	

func get_target_action_data() -> InputActionData:
	return _action_data
	

func set_requested_key(keycode : Key) -> void:
	_requested_key = keycode
	if (keycode != KEY_NONE):
		requested_key_set.emit(_requested_key)
		
	

func get_primary_keycode() -> Key:
	var keycodes = _action_data.get_keycodes()
	if keycodes.is_empty():
		return GameSettings.get_primary_event_keycode(_action_data)
	else:
		return keycodes.get(0)
	

func on_confirm_rebind() -> void:
	if _requested_key == KEY_NONE:
		return
	
	GameSettings.rebind_gameplay_action_key(_action_data, _requested_key)
	_requested_key = KEY_NONE

func verify_action() -> void:
	if not InputMap.has_action(_action_data.action_name):
		printerr("Input data {action_name} is not part of InputMap. Please check at {resource_path}".format(_action_data))
	
