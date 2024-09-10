class_name PlayerAnimations
extends Node

@export
var player_movement: CharacterMovement2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player_movement.new_valid_movement_input.connect(_update_run_animation.bind())
	player_movement.
	

func _update_run_animation(direction_input : Vector2) -> void:
	pass
	
