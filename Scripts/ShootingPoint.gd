class_name ShootingPoint
extends Node2D

signal shot
signal warned_started

@export_category("Depedencies")
@export
var _bullet: PackedScene
@export
var _shot_particles: GPUParticles2D
@export 
var _warning_particles: GPUParticles2D
@export 
var _timer: Timer

@export_category("Config")
@export_subgroup("Delay")
## If true, lifetime of the warning particles will be base duration
@export
var _is_delayed: bool = true
@export 
var _extra_delay_duration: float = 1
@export
var _cancel_shot_every: int = -1
@export
var _wait_for: ShootingPoint

@export_subgroup("Shooting")
@export
var _shot_warning_duration: float = 4
@export
var _shooting_direction: Vector2 = Vector2.ZERO
@export
var _bullet_speed: float = 45.0
@export
var _max_distance: float = 1000.0 
@export 
var _hide_warning_particles: bool = false

var _queued_bullet: Bullet
var _generated_bullet_count: int

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(_timer)
	assert(_shot_particles)
	assert(_bullet)
	assert(not _shooting_direction.is_zero_approx())
	assert(_shot_warning_duration > 0)
	
	_timer.one_shot = false
	if _is_delayed:
		if _shot_warning_duration < 1:
			printerr("shot warning cannot be under 1, setting it to 1")
			_shot_warning_duration = 1
		
		_delay_setup()
	else:
		_no_delay_setup()
	

func _delay_setup() -> void:
	if _is_extra_delayed():
		_set_timeout(_display_warning_particles.bind(), _extra_delay_duration)
	else:
		_display_warning_particles()
	

func _no_delay_setup() -> void:
	_generate_bullet(_shot_warning_duration)
	_set_timeout(_on_no_delay_warning_completed.bind(), _shot_warning_duration)
	

func _generate_bullet(delay : float) -> void:
	_generated_bullet_count += 1
	var bullet_instance: Bullet = _bullet.instantiate() as Bullet
	assert(bullet_instance)
	add_child(bullet_instance)
	bullet_instance.global_position = self.position
	
	var bullet_config: Bullet.BulletData = Bullet.BulletData.new()
	bullet_config.direction = _shooting_direction
	bullet_config.speed = _bullet_speed
	bullet_config.max_distance = _max_distance
	
	if _cancel_shot_every > 0 and _generated_bullet_count >= _cancel_shot_every + 1:
		_generated_bullet_count = 0
		bullet_config.max_distance = 0
		delay = -1
		
	
	bullet_instance.setup_bullet_for_shooting(delay, bullet_config)
	assert(not _queued_bullet)
	_queued_bullet = bullet_instance
	

func _display_warning_particles() -> void:
	if not _hide_warning_particles:
		_warning_particles.emitting = true
	warned_started.emit()
	_set_timeout(_on_delay_completed.bind(), _warning_particles.lifetime)
	

func _on_delay_completed() -> void:
	_generate_bullet(_shot_warning_duration)
	_set_timeout(_on_warning_completed.bind(), _shot_warning_duration)
	

func _on_warning_completed() -> void:
	_shoot_bullet()
	if _wait_for:
		await _wait_for.shot
	_delay_setup()
	


func _on_no_delay_warning_completed() -> void:
	_shoot_bullet()
	if _wait_for:
		await _wait_for.shot
	_no_delay_setup()
	

func _shoot_bullet() -> void:
	if is_instance_valid(_queued_bullet):
		_shot_particles.emitting = true
		_queued_bullet.shoot()
	
	_queued_bullet = null
	shot.emit()
	

func _set_timeout(callable : Callable, duration : float) -> void:
	if not _timer.is_stopped():
		_timer.stop()
	
	for connections in _timer.timeout.get_connections():
		_timer.timeout.disconnect(connections["callable"])
	
	_timer.wait_time = duration
	_timer.timeout.connect(callable)	
	_timer.start()
	

func _is_extra_delayed() -> bool:
	return _extra_delay_duration > 0
	
