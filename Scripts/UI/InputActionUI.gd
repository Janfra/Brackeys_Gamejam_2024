class_name InputActionUI
extends Control

@export
var key_label: Label

func on_show_requested_key(requested_key: Key) -> void:
	key_label.text = str(requested_key)
	
