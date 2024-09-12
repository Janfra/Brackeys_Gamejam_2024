extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	body_exited.connect(_first_exit.bind())
	

func _first_exit(_body : Node) -> void:
	GameTimer.set_is_timer_paused(false)
	body_exited.disconnect(_first_exit.bind())
	_connect_on_player_interaction.call_deferred()
	

func _on_player_interaction(_body : Node) -> void:
	print("interacted")
	var is_paused: bool = GameTimer.get_is_paused()
	if is_paused:
		GameTimer.set_is_timer_paused(false)
	else:
		GameTimer.reset_timer()
		
	

func _connect_on_player_interaction() -> void:
	body_entered.connect(_on_player_interaction.bind())
	body_exited.connect(_on_player_interaction.bind())
	
