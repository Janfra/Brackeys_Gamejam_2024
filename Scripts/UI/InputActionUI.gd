class_name InputActionUI
extends Control

@export
var _key_map: InputTextureMapData
@export
var _key_label: Label
@export 
var _key_texture: TextureRect

func _ready() -> void:
	assert(_key_label)
	assert(_key_texture)
	assert(_key_map)
	

func on_show_requested_key(requested_key: Key) -> void:
	_key_label.text = OS.get_keycode_string(requested_key)
	_key_texture.texture = _key_map.get_key_texture(requested_key)
	
