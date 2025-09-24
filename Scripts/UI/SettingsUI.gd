class_name SettingsUI
extends Control

@export 
var _input_listener: GenericInputListener

@export
var _rebind_uis: Array[InputActionUI]

var _modified_input_actions: Array[InputActionUI]
var _current_input_action: InputActionUI

func _ready() -> void:
	assert(_input_listener)
	for action_UI in _rebind_uis:
		action_UI.on_selected.connect(_on_input_rebind_ui_selected.bind())
		
	

func show_settings() -> void:
	visible = true
	

func _hide_settings() -> void:
	visible = false
	

func undo_and_close_settings() -> void:
	_undo_settings()
	_hide_settings()
	

func apply_and_close_settings() -> void:
	_apply_settings()
	_hide_settings()
	

func _undo_settings() -> void:
	for modified_input in _modified_input_actions:
		modified_input.clear_rebind_key()
		
	
	_modified_input_actions.clear()

func _apply_settings() -> void:
	for modified_input in _modified_input_actions:
		modified_input.confirm_changes()
		
	
	_modified_input_actions.clear()

func _set_requested_key_on_rebinder(keycode: Key) -> void:
	if (_current_input_action == null):
		return
	
	if _current_input_action.set_requested_rebind_key(keycode):
		if (not _modified_input_actions.has(_current_input_action)):
			_modified_input_actions.append(_current_input_action)
		
	
	_current_input_action = null
	


func _on_input_rebind_ui_selected(input_action: InputActionUI) -> void:
	# If the same is selected or given null, clear the selection
	if (input_action == _current_input_action or input_action == null):
		_input_listener.set_listening(false)
		_current_input_action = null
	else: # Otherwise update selection and listen
		_current_input_action = input_action
		_input_listener.set_listening(true)
		
	
