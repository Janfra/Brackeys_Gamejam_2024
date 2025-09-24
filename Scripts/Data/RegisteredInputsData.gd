@tool
class_name RegisteredInputsData
extends Resource

@export
var registered_inputs: Array[InputActionData]

@export
var _taken_keys: Dictionary[Key, InputActionData]

@warning_ignore("unused_private_class_variable")
@export_tool_button("Set taken keys")
var __Editor_get_taken = __Editor_set_taken_keys

func update_registered_inputs_cache() -> void:
	for input in registered_inputs:
		input.set_cached_keycodes_from_input_map()
		
	

func get_key_owner(keycode : Key) -> InputActionData:
	return _taken_keys.get(keycode)
	

func is_key_free(keycode : Key) -> bool:
	return not _taken_keys.has(keycode) # Is free if not taken
	

func _start_listening_for_signals() -> void:
	for input in registered_inputs:
		input.on_prerebind.connect(_remove_action_primary_taken_key.bind())
		input.on_rebind.connect(_add_action_primary_taken_key.bind())
	

func _stop_listening_for_signals() -> void:
	for input in registered_inputs:
		input.on_prerebind.disconnect(_remove_action_primary_taken_key.bind())
		input.on_rebind.disconnect(_add_action_primary_taken_key.bind())
	

func _remove_action_primary_taken_key(action_data: InputActionData, old_keycodes: Array[Key]) -> void:
	if not registered_inputs.has(action_data):
		return
	
	if old_keycodes.is_empty():
		return
	
	var keycode = old_keycodes.get(0) as Key
	_taken_keys.erase(keycode)
	

func _add_action_primary_taken_key(action_data: InputActionData) -> void:
	if not registered_inputs.has(action_data):
		return
	
	var keycodes: Array[Key] = action_data.get_keycodes()
	if keycodes.is_empty():
		return
	
	var keycode: Key = keycodes[0] as Key
	if _taken_keys.has(keycode):
		push_warning("Taken key {} was added, however it was already taken, will override from {}.".format([OS.get_keycode_string(keycode), _taken_keys[keycode].resource_path], "{}"))
	
	_taken_keys[keycode] = action_data
	

func __Editor_set_taken_keys() -> void:
	_taken_keys.clear()
	for input in registered_inputs:
		var keycodes: Array[Key] = input.get_keycodes()
		for keycode in keycodes:
			if _taken_keys.has(keycode):
				printerr("Keycode {keycode} has already been registered".format(keycode))
				continue
			else:
				_taken_keys[keycode] = input
	
