class_name ShootingPoint
extends Node2D

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

@export_subgroup("Shooting")
@export
var _shot_warning_duration: float = 4
@export
var _shooting_direction: Vector2 = Vector2.ZERO
@export
var _bullet_speed: float = 45.0
@export
var _max_distance: float = 1000.0

var _queued_bullet: Bullet

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
	

func _generate_bullet(delay : float) -> void:
	var bullet_instance: Bullet = _bullet.instantiate() as Bullet
	assert(bullet_instance)
	add_child(bullet_instance)
	bullet_instance.global_position = self.position
	
	var bullet_config: Bullet.BulletData = Bullet.BulletData.new()
	bullet_config.direction = _shooting_direction
	bullet_config.speed = _bullet_speed
	bullet_config.max_distance = _max_distance
	bullet_instance.setup_bullet_for_shooting(delay, bullet_config)
	assert(not _queued_bullet)
	_queued_bullet = bullet_instance
	

func _display_warning_particles() -> void:
	_warning_particles.emitting = true
	_set_timeout(_on_delay_completed.bind(), _warning_particles.lifetime)
	

func _on_delay_completed() -> void:
	_generate_bullet(_shot_warning_duration)
	_set_timeout(_on_warning_completed.bind(), _shot_warning_duration)
	

func _on_warning_completed() -> void:
	if is_instance_valid(_queued_bullet):
		_shot_particles.emitting = true
		_queued_bullet.shoot()
	
	_queued_bullet = null
	_delay_setup()
	

func _delay_setup() -> void:
	if _is_extra_delayed():
		_set_timeout(_display_warning_particles.bind(), _extra_delay_duration)
	else:
		_display_warning_particles()
	

func _no_delay_setup() -> void:
	_generate_bullet(_shot_warning_duration)
	_set_timeout(_on_no_delay_warning_completed.bind(), _shot_warning_duration)
	

func _on_no_delay_warning_completed() -> void:
	if is_instance_valid(_queued_bullet):
		_shot_particles.emitting = true
		_queued_bullet.shoot()
	
	_queued_bullet = null
	_no_delay_setup()
	

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
	
