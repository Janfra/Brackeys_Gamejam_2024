@tool
class_name InputTextureMapData
extends Resource

@export
var _key_to_texture: Dictionary[Key, Texture]
@export
var _default_texture: Texture

@export_tool_button("Add Common Key Values")
var _add_keys = _add_common_keys

func get_key_texture(keycode: Key) -> Texture:
	return _key_to_texture.get(keycode, _default_texture)
	

## Adds keycodes ranging from 32 to 96 to the key to texture dictionary when in editor
func _add_common_keys() -> void:
	if not Engine.is_editor_hint():
		return
	
	# Common keycodes range from 32 to 96, including all letters and numbers
	for i in range(32, 96):
		var keycode: Key = i as Key
		if not _key_to_texture.has(keycode):
			_key_to_texture[keycode] = Texture.new()
	
