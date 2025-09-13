class_name CameraMoveTrigger
extends Area2D

const CAMERA_TRANSITION_MAX_DURATION = 20.0
const CAMERA_TRANSITION_MIN_DURATION = 3.0
const CAMERA_TRANSITION_MAX_DISTANCE = 264.0
const CAMERA_TRANSITION_MIN_DISTANCE = 1.0

@export_category("Dependencies")
@export 
var _camera: Camera2D

@export_category("Config")
@export
var new_position: Vector2 = Vector2.ZERO
@export
var entrance_direction: Vector2
@export_range(-1.0, 1.0, 0.01)
var angle_tolerance: float
@export
var speed_curve: Curve

var old_position: Vector2 = Vector2.ZERO

var _is_position_set: bool = false
var _is_started: bool = false
var _target_position: Vector2 = Vector2.ZERO
var _transition_time: float = 0.0
var _transition_duration: float = CAMERA_TRANSITION_MAX_DURATION

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(_camera)
	body_entered.connect(_try_adjust_camera.bind())
	body_exited.connect(_try_adjust_camera.bind())
	

func _process(delta):
	if not _is_started or _target_position.is_equal_approx(_camera.global_position):
		_transition_time = 0.0
		_is_started = false
		return
	
	var cam_position: Vector2 = _camera.global_position
	_transition_time += delta
	var progress = min(remap(_transition_time, 0.0, _transition_duration, 0.0, 1.0), 1)
	var alpha = speed_curve.sample(progress)
	_camera.global_position = lerp(_camera.global_position, _target_position, alpha)
	if alpha == 1:
		_transition_time = 0.0
		_is_started = false
	

func _get_duration_based_on_distance() -> float:
	var distance_squared: float = (_target_position - _camera.global_position).length_squared()
	var max_distance_squared = CAMERA_TRANSITION_MAX_DISTANCE * CAMERA_TRANSITION_MAX_DISTANCE
	var min_distance_squared = CAMERA_TRANSITION_MIN_DISTANCE * CAMERA_TRANSITION_MIN_DISTANCE
	distance_squared = clamp(distance_squared, min_distance_squared, max_distance_squared)
	var normalised = (distance_squared - min_distance_squared) / (max_distance_squared - min_distance_squared)
	print("Values: %s %s %s %s" % [distance_squared, max_distance_squared, min_distance_squared, normalised])
	return lerp(CAMERA_TRANSITION_MIN_DURATION, CAMERA_TRANSITION_MAX_DURATION, normalised)
	

func _try_adjust_camera(body : Node) -> void:
	if body is PlayerMovement2D:
		var player: PlayerMovement2D = body as PlayerMovement2D
		var movement_direction = player.get_last_valid_input()
		if movement_direction.dot(entrance_direction) >= angle_tolerance:
			_move_camera_to_new_position()
		else:
			_move_camera_to_old_position()
		
		_is_started = true
		
	

func _move_camera_to_new_position() -> void:
	var cam_position = _camera.global_position
	if cam_position == new_position:
		return
	
	if not _is_position_set:
		old_position = cam_position
		_is_position_set = true
	
	_set_new_target(new_position)
	

func _move_camera_to_old_position() -> void:
	_set_new_target(old_position)
	

func _set_new_target(set_target : Vector2) -> void:
	if _target_position != set_target:
		_transition_time = 0.0
		_target_position = set_target
		_transition_duration = _get_duration_based_on_distance()
	
