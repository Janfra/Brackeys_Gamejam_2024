extends Node

## Aids with saving configurations and loading configurations

var _registered_gameplay_inputs := preload("uid://isxv8ja5x7w")
var _input_texture_map := preload("uid://r40gnw1dtr43")

enum REBIND_RESULT { OK, CONFLICT, INVALID_INPUT, }

func _ready() -> void:
	_registered_gameplay_inputs._start_listening_for_signals()
	# TODO: Load config file inputs and then update the input data
	

func get_primary_event_keycode(action_data: InputActionData) -> Key:
	var primary_event = _get_input_primary_event(action_data)
	if primary_event is InputEventKey:
		return primary_event.keycode if primary_event.keycode != KEY_NONE else primary_event.physical_keycode
	return KEY_NONE

func is_key_free(keycode: Key) -> bool:
	return _registered_gameplay_inputs.is_key_free(keycode)
	

func get_key_owner(keycode: Key) -> InputActionData:
	return _registered_gameplay_inputs.get_key_owner(keycode)
	

func rebind_gameplay_action_key(action_data: InputActionData, keycode: Key) -> REBIND_RESULT:
	var primary_event = _get_input_primary_event(action_data)
	if primary_event is InputEventKey:
		if is_key_free(keycode):
			primary_event.keycode = keycode
			action_data.on_action_events_rebinded()
			return REBIND_RESULT.OK
		else:
			var key_owner = get_key_owner(keycode)
			printerr("Requested key {} is already taken by {}".format([OS.get_keycode_string(keycode), key_owner.resource_path], "{}"))
			return REBIND_RESULT.CONFLICT
	
	return REBIND_RESULT.INVALID_INPUT

func get_key_texture(keycode: Key) -> Texture:
	return _input_texture_map.get_key_texture(keycode)
	

func _get_input_primary_event(action_data: InputActionData) -> InputEvent:
	var events: Array[InputEvent] = InputMap.action_get_events(action_data.action_name)
	return events.get(0)
	
