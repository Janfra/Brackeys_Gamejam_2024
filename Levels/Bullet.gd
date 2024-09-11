class_name Bullet
extends Area2D

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

var bullet_config: BulletData = BulletData.new()
var distance_travelled: Vector2 = Vector2.ZERO
var _is_active: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(_trail_particles)
	body_entered.connect(_clear_bullet.bind())
	_trail_particles.emitting = false
	

func shoot(data : BulletData) -> void:
	bullet_config = data
	_trail_particles.emitting = true
	_is_active = true
	

func _physics_process(delta) -> void:
	if not _is_active:
		return
	
	distance_travelled.x = bullet_config.speed * bullet_config.direction.x * delta
	distance_travelled.y = bullet_config.speed * bullet_config.direction.y * delta
	if distance_travelled.length_squared() >= bullet_config.max_distance * bullet_config.max_distance:
		print("reached max")
		queue_free()
	
	global_position += distance_travelled
	

func _clear_bullet(area: Node) -> void:
	queue_free()
	
