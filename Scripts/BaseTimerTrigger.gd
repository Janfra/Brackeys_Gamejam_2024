class_name BaseTimerTrigger
extends Area2D

enum ActivationType
{ 
	## Activates trigger after player leaves the trigger for the first time
	AFTER_FIRST_EXIT, 
	## Activates trigger as soon as scene is loaded
	ON_LOAD 
}

enum TriggerType
{
	## Switches between not being paused to resetting the timer/pausing
	RESET_SWITCH,
	## Switches between being paused and not being paused
	PAUSE_SWITCH,
	## Register time and end level
	LEVEL_COMPLETE,
	DISABLED
}

@export_category("Config")
## Sets if the trigger will work after first exit or instantly. If spawning in on load, it will activate instantly
@export
var activation_type: ActivationType = ActivationType.ON_LOAD
@export
var trigger_type: TriggerType = TriggerType.PAUSE_SWITCH
@export
var display_message: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_selected_trigger_type()
	

func _setup_selected_trigger_type() -> void:
	match activation_type:
		ActivationType.AFTER_FIRST_EXIT:
			_activate_after_first_exit_setup()
		ActivationType.ON_LOAD:
			_activate_on_load_setup()
		_:
			printerr("Trigger type not supported yet: %s" % activation_type)
			
	

## Setups interaction to be able to happen instantly
func _activate_on_load_setup() -> void:
	_connect_on_player_interaction()
	

## Setups interaction to happen only after first exit
func _activate_after_first_exit_setup() -> void:
	body_exited.connect(_first_exit.bind())
	

func _first_exit(_body : Node) -> void:
	GameTimer.set_is_timer_paused(false)
	body_exited.disconnect(_first_exit.bind())
	_connect_on_player_interaction.call_deferred()
	

func _connect_on_player_interaction() -> void:
	body_entered.connect(_on_player_interaction.bind())
	body_exited.connect(_on_player_interaction.bind())
	

func _on_player_interaction(_body : Node) -> void:
	_activate_based_on_trigger_type()
	

func _activate_based_on_trigger_type() -> void:
	match trigger_type:
		TriggerType.RESET_SWITCH:
			_switch_reset_state()
		
		TriggerType.PAUSE_SWITCH:
			_switch_pause_state()
		
		TriggerType.LEVEL_COMPLETE:
			_complete_level()
		
		TriggerType.DISABLED:
			return
		
		_:
			printerr("Trigger type activation is not supported yet: %s" % trigger_type)
	

func _complete_level() -> void:
	GameTimer.register_time()
	GameManager.level_has_been_completed()
	trigger_type = TriggerType.DISABLED
	

func _switch_pause_state() -> void:
	var switch_is_paused = !GameTimer.get_is_paused()
	GameTimer.set_is_timer_paused(switch_is_paused)
	if switch_is_paused and not display_message.is_empty():
		GameTimer.display_message_on_timer_ui(display_message)
	

func _switch_reset_state() -> void:
	var is_paused: bool = GameTimer.get_is_paused()
	if is_paused:
		GameTimer.set_is_timer_paused(false)
	else:
		GameTimer.reset_timer()
	
