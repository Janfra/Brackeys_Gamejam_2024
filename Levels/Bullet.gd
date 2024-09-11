class_name Bullet
extends Area2D

const VECTOR_TO_ROTATION = { Vector2.DOWN: 0.0, Vector2.LEFT: 90.0,  Vector2.UP: 180.0, Vector2.RIGHT: 270.0 }

const SHADER_OPACITY_PARAM = "OpacityExtent"
const SHADER_NO_OPACITY = 0
const SHADER_MAX_OPACITY = 6

const INVALID_DELAY = -1

class BulletData:
	var speed: float
	var max_distance: float
	var direction: Vector2 
	
	func _init():
		speed = 45.0
		max_distance = 50.0
		direction = Vector2.ZERO
	

@export_category("Dependecies")
@export
var _trail_particles: GPUParticles2D
@export
var _explosion_particles: GPUParticles2D
@export
var _sprite: Sprite2D
@export
var _animation_player: AnimationPlayer

var bullet_config: BulletData = BulletData.new()
var distance_travelled: Vector2 = Vector2.ZERO
var _is_active: bool = false

var _shoot_delay: float = INVALID_DELAY
var _current_delay: float = INVALID_DELAY
var _shader: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_assert_checks()
	body_entered.connect(_clear_bullet.bind())
	_trail_particles.emitting = false
	_setup_shader()
	

func setup_bullet_for_shooting(set_duration : float, data : BulletData) -> void:
	_shoot_delay = set_duration
	_current_delay = _shoot_delay
	_animation_player.play("appear")
	bullet_config = data
	_setup_bullet_rotation(data.direction)
	

func shoot() -> void:
	_trail_particles.emitting = true
	_is_active = true
	

func _physics_process(delta : float) -> void:
	_display_delay_progress(delta)
	if not _is_active:
		return
	_move_bullet(delta)
	

func _move_bullet(delta : float) -> void:
	distance_travelled.x = bullet_config.speed * bullet_config.direction.x * delta
	distance_travelled.y = bullet_config.speed * bullet_config.direction.y * delta
	if distance_travelled.length_squared() >= bullet_config.max_distance * bullet_config.max_distance:
		print("reached max")
		_clear_bullet(null)
	
	global_position += distance_travelled
	

func _clear_bullet(_area: Node) -> void:
	_trail_particles.emitting = false
	_sprite.hide()
	_explosion_particles.finished.connect(queue_free.bind())
	_explosion_particles.emitting = true
	

func _display_delay_progress(delta : float) -> void:
	if _shoot_delay < 0:
		return
	
	if not _shader:
		return
	
	var opacity = max(remap(_current_delay, _shoot_delay, 0, SHADER_MAX_OPACITY, SHADER_NO_OPACITY), 0)
	_shader.set_shader_parameter(SHADER_OPACITY_PARAM, opacity)
	_current_delay -= delta
	if _current_delay <= 0:
		_shoot_delay = INVALID_DELAY
	

func _setup_bullet_rotation(shooting_direction : Vector2) -> void:
	var vector = shooting_direction.normalized()
	if VECTOR_TO_ROTATION.has(vector):
		rotation_degrees = VECTOR_TO_ROTATION[vector]
	

func _assert_checks() -> void:
	assert(_trail_particles)
	assert(_sprite)
	assert(_explosion_particles)
	assert(_animation_player)
	

func _setup_shader() -> void:
	_shader = _sprite.material as ShaderMaterial
	assert(_shader)
	_shader.shader = _shader.shader.duplicate()
	_shader.set_shader_parameter(SHADER_OPACITY_PARAM, SHADER_MAX_OPACITY)
	
