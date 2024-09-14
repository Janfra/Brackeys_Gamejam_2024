extends Node

## Keeps data for the times achieved by the player

signal pause_state_changed(is_paused : bool) 
signal new_record(time : float)
signal time_updated(time : float)
signal time_reset
signal ui_message_used(display : String)

var _is_paused: bool = true
var _current_time: float = 0.0
var _best_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.player_losed.connect(reset_timer.bind())
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta) -> void:
	if _is_paused:
		return
	
	_current_time += delta
	time_updated.emit(_current_time)
	

func display_message_on_timer_ui(display : String) -> void:
	ui_message_used.emit(display)
	

func set_level_record_time(time : float) -> void:
	_best_time = time
	

func timer_completed() -> void:
	_current_time = 0.0
	set_is_timer_paused(true)
	

func reset_timer() -> void:
	_current_time = 0.0
	set_is_timer_paused(true)
	time_reset.emit()
	

func get_is_paused() -> bool:
	return _is_paused
	 

func set_is_timer_paused(set_is_paused : bool) -> void:
	_is_paused = set_is_paused
	pause_state_changed.emit(_is_paused)
	

func register_time() -> void:
	if _current_time < _best_time or _best_time == 0:
		_best_time = _current_time
		new_record.emit(_best_time)
	timer_completed()
	
