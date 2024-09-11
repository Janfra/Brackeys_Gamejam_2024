class_name ShootingPoint
extends Node2D

@export_category("Depedencies")
@export
var _bullet: PackedScene
@export
var _shot_particles: GPUParticles2D
@export 
var _timer: Timer

@export_category("Config")
@export 
var _delay_duration: float = 4
@export
var _warning_duration: float = 4
@export
var _shooting_direction: Vector2

var _queued_bullet: Bullet

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(_timer)
	assert(_shot_particles)
	assert(_bullet)
	assert(not _shooting_direction.is_zero_approx())
	
	_timer.one_shot = false
	_set_timeout(_on_delay_completed.bind(), _delay_duration)
	

func _generate_bullet(delay : float) -> void:
	print("Generating")
	var bullet_instance: Bullet = _bullet.instantiate() as Bullet
	assert(bullet_instance)
	add_child(bullet_instance)
	bullet_instance.global_position = self.position
	
	var bullet_config: Bullet.BulletData = Bullet.BulletData.new()
	bullet_config.direction = _shooting_direction
	bullet_instance.setup_bullet_for_shooting(delay, bullet_config)
	assert(not _queued_bullet)
	_queued_bullet = bullet_instance
	

func _on_delay_completed() -> void:
	print("Delay finished")
	_generate_bullet(_warning_duration)
	_set_timeout(_on_warning_completed.bind(), _warning_duration)
	

func _on_warning_completed() -> void:
	print("Warning complete")
	if is_instance_valid(_queued_bullet):
		_shot_particles.emitting = true
		_queued_bullet.shoot()
		_queued_bullet = null
	
	_set_timeout(_on_delay_completed.bind(), _delay_duration)
	

func _set_timeout(callable : Callable, duration : float) -> void:
	if not _timer.is_stopped():
		_timer.stop()
	
	for connections in _timer.timeout.get_connections():
		_timer.timeout.disconnect(connections["callable"])
	
	_timer.wait_time = duration
	_timer.timeout.connect(callable)	
	_timer.start()
	
