extends Control

# UI references
@onready var control: Control = $"."  
@onready var main: VBoxContainer = $main
@onready var shopui: Panel = $shopui
@onready var countdown_label: Label = $shopui/CountdownLabel

# Timer variables
const DURATION := 10 * 60 # 10 minutes in seconds
var remaining_time: float = DURATION

# --- UI Logic ---
func _ready() -> void:
	main.visible = true
	shopui.visible = false
	countdown_label.text = _format_time(int(remaining_time))

func _on_settings_pressed() -> void:
	main.visible = false
	shopui.visible = true

func _on_button_pressed() -> void:
	_ready()

func _on_shop_button_down() -> void:
	shopui.visible = true

func _on_back_button_down() -> void:
	shopui.visible = false

# --- Countdown Timer (real-time) ---
func _process(delta: float) -> void:
	remaining_time -= delta
	if remaining_time <= 0:
		remaining_time = DURATION  # reset to 10 minutes
	countdown_label.text = _format_time(int(remaining_time))

func _format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var secs = seconds % 60
	return "%02d:%02d" % [minutes, secs]
