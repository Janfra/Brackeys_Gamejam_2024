class_name PlayerAnimations
extends Node

enum FacingDirection {UP, DOWN, RIGHT, LEFT}
#region Animation Names
## Const with "ANIMATIONS" suffix are used with FacingDirection to do string arithmetic to get the desired direction 
const IDLE_ANIMATIONS = "idle_"
const IDLE_DOWN = "idle_down"
const IDLE_UP = "idle_up"
const IDLE_RIGHT = "idle_right"
const IDLE_LEFT = "idle_left"

const RUN_ANIMATIONS = "run_"
const RUN_DOWN = "run_down"
const RUN_UP = "run_up"
const RUN_RIGHT = "run_right"
const RUN_LEFT = "run_left"
#endregion
class QueuedAnimation:
	var animation: String
	var play_speed: float
	

@export
var _player_movement: CharacterMovement2D
@export
var _animation_player: AnimatedSprite2D

var _current_facing_direction: FacingDirection = FacingDirection.DOWN
var _currently_queued_animation: QueuedAnimation = QueuedAnimation.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if not _player_movement:
		return
	
	_player_movement.new_valid_movement_input.connect(_update_run_animation.bind())
	_player_movement.stopped_moving.connect(_update_idle_animation.bind())
	

func _update_run_animation(direction_input : Vector2) -> void:
	var vertical_direction = direction_input.y
	var horizontal_direction = direction_input.x
	
	if not is_zero_approx(vertical_direction):
		_set_vertical_facing_direction(vertical_direction)
	else:
		_set_horizontal_facing_direction(horizontal_direction)
	
	var animation_to_play = _get_animation_based_on_current_direction(RUN_ANIMATIONS)
	_play_animation(animation_to_play, true)

func _update_idle_animation() -> void:
	var animation_to_play = _get_animation_based_on_current_direction(IDLE_ANIMATIONS)
	_play_animation(animation_to_play, true)
	

func _set_vertical_facing_direction(y_input : float) -> void:
	if y_input > 0:
		_current_facing_direction = FacingDirection.DOWN
	else:
		_current_facing_direction = FacingDirection.UP
	

func _set_horizontal_facing_direction(x_input : float) -> void:
	if x_input > 0:
		_current_facing_direction = FacingDirection.RIGHT
	else:
		_current_facing_direction = FacingDirection.LEFT
	

func _get_animation_based_on_current_direction(animation_prefix : String) -> String:
	animation_prefix += FacingDirection.keys()[_current_facing_direction]
	return animation_prefix.to_lower()
	

func _play_animation(animation : String, override : bool = false, play_speed : float = 1.0) -> void:
	if not _animation_player:
		return
	
	if override:
		if _animation_player.animation_looped.is_connected(_play_animation_on_finished.bind()):
			_animation_player.animation_looped.disconnect(_play_animation_on_finished.bind())
		_animation_player.play(animation, play_speed)
	else:
		if _animation_player.is_playing():
			_currently_queued_animation.animation = animation
			_currently_queued_animation.play_speed = play_speed
			_animation_player.animation_looped.connect(_play_animation_on_finished.bind())
		else:
			_animation_player.play(animation, play_speed)
		
	

func _play_animation_on_finished() -> void:
	_animation_player.play(_currently_queued_animation.animation, _currently_queued_animation.play_speed)
	
