class_name Health
extends Node

## Simple health component, for now only planning to instantly die on hit

signal died

static var node_to_health: Dictionary

@export_category("Dependencies")
@export
var parent_node: Node

@export_category("Config")
@export
var health: int = 1
var is_alive: bool = true

static func get_health_from_node(node : Node) -> Health:
	if node_to_health.has(node):
		return node_to_health[node]
	else:
		return null
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_instance_valid(parent_node) and not node_to_health.has(parent_node):
		node_to_health[parent_node] = self
	else:
		assert(false)
	

func _exit_tree() -> void:
	if node_to_health.has(parent_node):
		node_to_health.erase(parent_node)
	else:
		assert(false)
	

func deal_damage(damage : int) -> void:
	health -= damage
	if health <= 0 and is_alive:
		died.emit()
		is_alive = false
	
