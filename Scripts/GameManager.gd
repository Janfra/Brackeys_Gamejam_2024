extends Node

## Autload to handle game states

signal player_losed
signal player_died
signal level_completed
signal loading_next_level(level_data : LevelData)

const SCENE_TRANSITION_SCENE = preload("res://Scenes/scene_transition.tscn")
const TRANSITION_ANIMATION = "fade_in"
const DELAY_AFTER_COMPLETION = 0.5

enum GameStates
{
	MAIN_MENU,
	PLAY,
	LOSE,
	PAUSE,
}

var _initial_state: GameStates = GameStates.PLAY
var _current_state: GameStates = _initial_state

var _is_transitioning: bool
var _transition: AnimationPlayer
var _main_scene = load(ProjectSettings.get_setting("application/run/main_scene"))
var _current_level: LevelData

func set_level_data(data : LevelData) -> void:
	_current_level = data
	

func load_next_level(data : LevelData) -> void:
	if not data or not data.is_valid():
		return
	
	if data == _current_level:
		printerr("Trying to load same level")
		return
	
	_current_level = data
	loading_next_level.emit(data)
	_load_level_from_path(data.level)
	

func level_has_been_completed() -> void:
	await get_tree().create_timer(DELAY_AFTER_COMPLETION, false).timeout
	level_completed.emit()
	

func player_has_died() -> void:
	player_died.emit()
	

func set_game_state(game_state : GameStates) -> void:
	_current_state = game_state
	_handle_new_game_state()
	

func _handle_new_game_state() -> void:
	match _current_state:
		GameStates.LOSE:
			player_losed.emit()
			if _current_level and _current_level.is_valid():
				_load_level_from_path(_current_level.level)
			else:
				_load_level(_main_scene)
			
		
		_:
			printerr("Game State yet not defined")
	

func _load_level_from_path(level_path : String) -> void:
	if _is_transitioning:
		printerr("Already transitioning")
		return
	
	if not level_path or not level_path.is_absolute_path():
		printerr("Attempting to load invalid level")
		return
	
	var nodeTree:SceneTree = get_tree()
	if !_transition:
		if !_create_transition():
			return
	
	# Start transitioning and wait for animation to end
	_is_transitioning = true
	_transition.play(TRANSITION_ANIMATION)
	await _transition.animation_finished
	
	# Start changing scene
	nodeTree.change_scene_to_file(level_path)
	
	# Double checking that we didnt lose the transition when changing scene
	if not _transition:
		printerr("Transition no longer valid")
		_is_transitioning = false
		return
	
	_transition.play_backwards(TRANSITION_ANIMATION)
	_is_transitioning = false
	print("Transitioned to new level")
	

func _load_level(level : PackedScene) -> void:
	if _is_transitioning:
		printerr("Already transitioning")
		return
	
	if not level or not level.can_instantiate():
		printerr("Attempting to load invalid level")
		return
	
	var nodeTree:SceneTree = get_tree()
	if not _transition:
		if !_create_transition():
			return
	
	# Start transitioning and wait for animation to end
	_is_transitioning = true
	_transition.play(TRANSITION_ANIMATION)
	await _transition.animation_finished
	
	# Start changing scene
	nodeTree.change_scene_to_packed(level)
	
	# Double checking that we didnt lose the transition when changing scene
	if not _transition:
		printerr("Transition no longer valid")
		_is_transitioning = false
		return
	
	_transition.play_backwards(TRANSITION_ANIMATION)
	_is_transitioning = false
	print("Transitioned to new level")
	

## Setups reference to scene transition
func _create_transition() -> bool:
	# INFO: Create and find the animation player
	var transitionInstance = SCENE_TRANSITION_SCENE.instantiate()
	if transitionInstance is AnimationPlayer:
		_transition = transitionInstance as AnimationPlayer
	else:
		var instanceChildren = transitionInstance.get_children()
		for children in instanceChildren:
			if children is AnimationPlayer:
				_transition = children as AnimationPlayer
	
	if not _transition:
		assert(false, "No transition available")
		return false
		
	
	# INFO: Parent it to keep it active
	add_child(_transition.owner)
	if _transition.owner:
		_transition.owner.owner = self
	else:
		_transition.owner = self
	
	print("Generated transition scene")
	return true
	
