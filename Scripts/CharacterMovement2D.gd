class_name PlayerMovement2D
extends CharacterBody2D

signal input_cancelled_acceleration
signal new_valid_movement_input(input : Vector2)
signal stopped_moving

const MOVE_LEFT = "move_left"
const MOVE_RIGHT = "move_right"
const MOVE_UP = "move_up"
const MOVE_DOWN = "move_down"

@export_category("Dependencies")
@export
var _health : Health

@export_category("Config")
@export 
var _base_speed: float = 300.0
@export 
var _deceleration_percentage: float = 0.6
@export 
var _acceleration_rate: float = 1.0

## -1 is opposite direction, 1 is same direction, 0 is sideways
@export_range(-1.0, 1.0, 0.05) 
var _decelerate_angle_tolerance = 0.0

var _acceleration: float
var _last_frame_direction: Vector2
var _last_input_direction: Vector2

var _is_enabled: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
# var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	_health.died.connect(_disable_movement.bind())
	

func _disable_movement() -> void:
	_is_enabled = false
	

func _enable_movement() -> void:
	_is_enabled = true
	

func _physics_process(_delta) -> void:
	if not _is_enabled:
		return
	
	# Get the input direction and handle the movement/deceleration.
	var direction_input: Vector2 = _get_direction_input()
	
	if direction_input.is_zero_approx():
		_decelerate()
		if _has_stopped_moving():
			stopped_moving.emit()
		
	else:
		if get_real_velocity().is_zero_approx():
			stopped_moving.emit()
			_clear_accumulated_acceleration()
		
		if _is_opposite_direction_to_movement(direction_input, _decelerate_angle_tolerance):
			_clear_accumulated_acceleration()
		_accelerate(direction_input)
		_register_valid_movement_input(direction_input)
		
	
	_last_frame_direction = direction_input
	move_and_slide()

func _get_direction_input() -> Vector2:
	var horizontal_direction: float = Input.get_axis(MOVE_LEFT, MOVE_RIGHT)
	var vertical_direction: float = Input.get_axis(MOVE_UP, MOVE_DOWN)
	return Vector2(horizontal_direction, vertical_direction).normalized()
	

func _decelerate() -> void:
	var decelaration_rate = (_base_speed * _deceleration_percentage)
	velocity.x = move_toward(velocity.x, 0, decelaration_rate)
	velocity.y = move_toward(velocity.y, 0, decelaration_rate)
	_acceleration = move_toward(_acceleration, 0, decelaration_rate)
	

func _has_stopped_moving() -> bool:
	return velocity.is_zero_approx()
	

func _accelerate(direction : Vector2) -> void:
	_acceleration = move_toward(_acceleration, _base_speed, _acceleration_rate)
	velocity.x = direction.x * _acceleration
	velocity.y = direction.y * _acceleration
	

func _is_opposite_direction_to_movement(direction : Vector2, angle_tolerance : float) -> bool:
	if direction.is_zero_approx():
		return false
	
	if _last_frame_direction.is_zero_approx():
		return _last_input_direction.dot(direction) <= angle_tolerance
	return _last_frame_direction.dot(direction) <= angle_tolerance
	

func _clear_accumulated_acceleration() -> void:
	_acceleration = 0
	input_cancelled_acceleration.emit()
	

func _register_valid_movement_input(direction_input : Vector2) -> void:
	if not _last_input_direction.is_equal_approx(direction_input) or _last_frame_direction.is_zero_approx():
		new_valid_movement_input.emit(direction_input)
	_last_input_direction = direction_input
	
