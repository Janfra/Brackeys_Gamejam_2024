class_name InputActionUI
extends Control

@export
var _input_actions: InputSettingsActions
@export
var _key_label: Label

signal on_selected(input_action: InputActionUI)

func _ready() -> void:
	assert(_key_label)
	assert(_input_actions)
	
	on_show_requested_key(_input_actions.get_primary_keycode())
	

func set_requested_rebind_key(keycode: Key) -> bool:
	if GameSettings.is_key_free(keycode):
		_input_actions.set_requested_key(keycode)
	else:
		var owner_action: InputActionData = GameSettings.get_key_owner(keycode)
		if owner_action == _input_actions.get_target_action_data():
			_set_key_label_text(keycode)
		return false
	
	return true;
	

func clear_rebind_key() -> void:
	_input_actions.set_requested_key(KEY_NONE)
	

func confirm_changes() -> void:
	_input_actions.on_confirm_rebind()
	

func on_show_requested_key(requested_key: Key) -> void:
	_set_key_label_text(requested_key)
	

func _set_key_label_text(keycode: Key) -> void:
	_key_label.text = OS.get_keycode_string(keycode)
	

func _select() -> void:
	on_selected.emit(self)
	
