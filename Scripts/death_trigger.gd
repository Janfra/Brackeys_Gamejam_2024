class_name DeathTrigger
extends Area2D

enum SignalType
{
	WARNING,
	SHOT
}

@export
var _explosion_particles: GPUParticles2D
@export
var _sprite: Sprite2D
@export
var _wait_for: ShootingPoint
@export
var _wait_signal: SignalType

var _is_active: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(_kill_object.bind())
	if _wait_for:
		match _wait_signal:
			SignalType.WARNING:
				#_wait_for.warned_started.connect()
				pass
	

func _kill_object(body : Node) -> void:
	var health: Health = Health.get_health_from_node(body)
	if health:
		health.deal_damage(100)
		_sprite.hide()
		_explosion_particles.emitting = true
	
