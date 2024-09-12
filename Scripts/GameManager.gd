extends Node

## Autload to handle game states

signal player_losed
signal player_died

const SCENE_TRANSITION_SCENE = preload("res://Scenes/scene_transition.tscn")
const TRANSITION_ANIMATION = "fade_in"

enum GameStates
{
	MainMenu,
	Play,
	Lose,
	Pause,
}

var _initial_state: GameStates = GameStates.Play
var _current_state: GameStates = _initial_state

var _is_transitioning: bool
var _transition: AnimationPlayer
var _main_scene = load(ProjectSettings.get_setting("application/run/main_scene"))

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func player_has_died() -> void:
	player_died.emit()
	

func set_game_state(game_state : GameStates) -> void:
	_current_state = game_state
	_handle_new_game_state()
	

func _handle_new_game_state() -> void:
	match _current_state:
		GameStates.Lose:
			player_losed.emit()
			load_level(_main_scene)
		
		_:
			printerr("Game State yet not defined")
	

func load_level(level : PackedScene) -> void:
	if _is_transitioning:
		printerr("Already transitioning")
		return
	
	if !level || !level.can_instantiate():
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
	nodeTree.change_scene_to_packed(level)
	
	# Double checking that we didnt lose the transition when changing scene
	if !_transition:
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
	
	if !_transition:
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
	
