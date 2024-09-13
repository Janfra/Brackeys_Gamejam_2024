class_name Bullet
extends Area2D

const VECTOR_TO_ROTATION = { Vector2.DOWN: 0.0, Vector2.LEFT: 90.0,  Vector2.UP: 180.0, Vector2.RIGHT: 270.0 }
const INVALID_DELAY = -1
const BULLET_DAMAGE = 1

#region Shader Consts
const SHADER_OPACITY_PARAM = "OpacityExtent"
const SHADER_NO_OPACITY = 0
const SHADER_MAX_OPACITY = 2.5
#endregion

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
@export
var _collision_shape: CollisionShape2D

var bullet_config: BulletData = BulletData.new()
var distance_travelled: Vector2 = Vector2.ZERO
var _velocity: Vector2 = Vector2.ZERO
var _is_active: bool = false
var _has_been_disabled: bool = false

#region Shader Vars
var _shoot_delay: float = INVALID_DELAY
var _current_delay: float = INVALID_DELAY
var _shader: ShaderMaterial
#endregion

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_assert_checks()
	body_entered.connect(_handle_collision.bind())
	area_entered.connect(_handle_collision.bind())
	_trail_particles.emitting = false
	_setup_shader()
	

func setup_bullet_for_shooting(set_duration : float, data : BulletData) -> void:
	_shoot_delay = set_duration
	_current_delay = _shoot_delay
	_animation_player.play("appear")
	bullet_config = data
	_setup_bullet_rotation(data.direction)
	

func shoot() -> void:
	if _has_been_disabled:
		return
	
	_trail_particles.emitting = true
	_is_active = true
	

func _physics_process(delta : float) -> void:
	_display_delay_progress(delta)
	if not _is_active:
		return
	_move_bullet(delta)
	

func _move_bullet(delta : float) -> void:
	_velocity.x = bullet_config.speed * bullet_config.direction.x * delta
	_velocity.y = bullet_config.speed * bullet_config.direction.y * delta
	distance_travelled += _velocity
	if distance_travelled.length_squared() >= bullet_config.max_distance * bullet_config.max_distance:
		print("reached max")
		_disable_bullet()
	
	global_position += _velocity
	

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
	else:
		assert(false)
	

func _handle_collision(area: Node) -> void:
	if area is Bullet:
		_handle_bullet_collision(area)
		return
		
	
	var health: Health = Health.get_health_from_node(area)
	if health:
		print("Hit object with health")
		health.deal_damage(BULLET_DAMAGE)
	_disable_bullet.call_deferred()
	

func _handle_bullet_collision(other_bullet : Bullet) -> void:
	if other_bullet._is_active and _is_active:
		_disable_bullet.call_deferred()
	

func _disable_bullet() -> void:
	_is_active = false
	_collision_shape.disabled = true
	_trail_particles.emitting = false
	_sprite.hide()
	_has_been_disabled = true
	
	var free_callable: Callable = queue_free.bind()
	if not _explosion_particles.finished.is_connected(free_callable):
		_explosion_particles.finished.connect(free_callable)
	_explosion_particles.emitting = true
	

func _assert_checks() -> void:
	assert(_trail_particles)
	assert(_sprite)
	assert(_explosion_particles)
	assert(_animation_player)
	

func _setup_shader() -> void:
	_shader = _sprite.material as ShaderMaterial
	assert(_shader)
	_shader.set_shader_parameter(SHADER_OPACITY_PARAM, SHADER_MAX_OPACITY)
	
