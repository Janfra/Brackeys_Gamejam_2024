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
	
	_timer.one_shot = false
	_set_timeout(_on_delay_completed.bind(), _delay_duration)
	

func _generate_bullet() -> void:
	print("Generating")
	var bullet_instance: Bullet = _bullet.instantiate() as Bullet
	assert(bullet_instance)
	
	bullet_instance.global_position = self.position
	bullet_instance.owner = self
	add_sibling(bullet_instance)
	
	assert(not _queued_bullet)
	_queued_bullet = bullet_instance
	

func _on_delay_completed() -> void:
	print("Delay finished")
	_generate_bullet()
	_set_timeout(_on_warning_completed.bind(), _warning_duration)
	

func _on_warning_completed() -> void:
	print("Warning complete")
	_shot_particles.emitting = true
	
	if is_instance_valid(_queued_bullet):
		var bullet_config: Bullet.BulletData = Bullet.BulletData.new()
		bullet_config.direction = _shooting_direction
		_queued_bullet.shoot(bullet_config)
	
	_set_timeout(_on_delay_completed.bind(), _delay_duration)
	

func _set_timeout(callable : Callable, duration : float) -> void:
	if not _timer.is_stopped():
		_timer.stop()
	
	for connections in _timer.timeout.get_connections():
		_timer.timeout.disconnect(connections["callable"])
	
	_timer.wait_time = duration
	_timer.timeout.connect(callable)	
	_timer.start()
	
