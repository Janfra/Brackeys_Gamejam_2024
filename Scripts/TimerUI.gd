extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	GameTimer.time_updated.connect(_update_displayed_timer.bind())
	GameTimer.time_reset.connect(_update_displayed_timer.bind(0.0))
	GameTimer.new_record.connect(_display_new_record.bind())
	GameTimer.ui_message_used.connect(_display_message.bind())
	GameManager.player_died.connect(_disable_display.bind())
	

func _update_displayed_timer(time : float) -> void:
	text = "%.1f" % time
	

func _disable_display() -> void:
	GameTimer.time_updated.disconnect(_update_displayed_timer.bind())
	GameTimer.time_reset.disconnect(_update_displayed_timer.bind(0.0))
	

func _display_new_record(time : float) -> void:
	text = "NEW RECORD\n %.1f" % time
	

func _display_message(display : String) -> void:
	text = display
	
