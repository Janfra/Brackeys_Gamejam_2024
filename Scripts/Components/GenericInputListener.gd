class_name GenericInputListener
extends Node

var _is_listening: bool
var last_input_key: Key

signal on_key_input_registered(keycode : Key)

func _unhandled_input(event: InputEvent) -> void:
	if not _is_listening:
		return
	
	if !event.is_action_type():
		return
	
	if event.is_echo():
		return
	
	if event is InputEventKey:
		last_input_key = event.keycode
		on_key_input_registered.emit(event.keycode)
	
	_is_listening = false
	get_viewport().set_input_as_handled()

func toggle_listening() -> void:
	_is_listening = not _is_listening # toggle
	

func set_listening(is_listening: bool) -> void:
	_is_listening = is_listening
	
