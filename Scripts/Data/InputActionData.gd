class_name InputActionData
extends Resource

@export 
var action_name: StringName

@export
var display_name: String

var _cache_keycodes: Array[Key]

signal on_prerebind(action_data: InputActionData, keycodes: Array[Key])
signal on_rebind(action_data: InputActionData)

func get_keycodes() -> Array[Key]:
	if _cache_keycodes.is_empty():
		set_cached_keycodes_from_input_map()
	return _cache_keycodes
	

func on_action_events_rebinded() -> void:
	on_prerebind.emit(self, _cache_keycodes)
	set_cached_keycodes_from_input_map()
	on_rebind.emit(self)
	

func set_cached_keycodes_from_input_map() -> void:
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
		
