extends Control

# --- UI references ---
@onready var control: Control = $"."  
@onready var main: VBoxContainer = $main
@onready var shopui: Panel = $shopui
@onready var countdown_label: Label = $shopui/CountdownLabel
@onready var settings: Panel = $settings
@onready var inventory: Panel = $inventory
@onready var leaderboards: Panel = $leaderboards
@onready var profile: Panel = $profile

# --- Timer variables ---
const DURATION := 10 * 60 # 10 minutes in seconds
var remaining_time: float = DURATION

# --- Setup ---
func _ready() -> void:
	main.visible = true
	_hide_all_panels()
	countdown_label.text = _format_time(int(remaining_time))

# --- Helper to hide all popups ---
func _hide_all_panels() -> void:
	shopui.visible = false
	settings.visible = false
	inventory.visible = false
	leaderboards.visible = false
	profile.visible = false

# --- Shop ---
func _on_shop_button_down() -> void:
	_hide_all_panels()
	shopui.visible = true

func _on_back_button_down() -> void:
	shopui.visible = false

# --- Settings ---
func _on_settings_button_down() -> void:
	_hide_all_panels()
	settings.visible = true

func _on_backk_button_down() -> void:
	settings.visible = false

# --- Profile ---
func _on_profile_button_down() -> void:
	_hide_all_panels()
	profile.visible = true

func _on_back_profile_button_down() -> void:
	profile.visible = false

# --- Inventory ---
func _on_inventory_button_down() -> void:
	_hide_all_panels()
	inventory.visible = true

func _on_back_inventory_button_down() -> void:
	inventory.visible = false

# --- Leaderboards ---
func _on_leaderboards_button_down() -> void:
	_hide_all_panels()
	leaderboards.visible = true

func _on_back_leaderboards_button_down() -> void:
	leaderboards.visible = false

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
