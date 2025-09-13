class_name InputSettingsActions
extends Node

@export
var _action_data: InputActionData
var _is_listening: bool
var _requested_key: Key

signal requested_key_set(requested_key: Key)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_listening:
		return
	
	if !event.is_action_type():
		return
	
	if event.is_echo():
		return
	
	if event is InputEventKey:
		_requested_key = event.keycode
		requested_key_set.emit(_requested_key)
	
	_is_listening = false
	get_viewport().set_input_as_handled()

func toggle_listening() -> void:
	_is_listening = not _is_listening # toggle
	

func verify_action() -> void:
	if not InputMap.has_action(_action_data.action_name):
		printerr("Input data {action_name} is not part of InputMap. Please check at {resource_path}".format(_action_data))
	
