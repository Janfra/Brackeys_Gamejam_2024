extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
	GameTimer.time_updated.connect(_update_displayed_timer.bind())
	GameTimer.time_reset.connect(_update_displayed_timer.bind(0.0))
	GameManager.player_died.connect(_disable_display.bind())
	

func _update_displayed_timer(time : float) -> void:
	text = "%10.1f" % time
	

func _disable_display() -> void:
	GameTimer.time_updated.disconnect(_update_displayed_timer.bind())
	GameTimer.time_reset.disconnect(_update_displayed_timer.bind(0.0))
	
