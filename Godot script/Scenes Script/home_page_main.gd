extends Control

# UI references
@onready var control: Control = $"."  
@onready var main: VBoxContainer = $main
@onready var shopui: Panel = $shopui
@onready var countdown_label: Label = $shopui/CountdownLabel
@onready var settings: Panel = $settings
@onready var inventory: Panel = $inventory
@onready var leaderboards: Panel = $leaderboards
@onready var profile: Panel = $profile


# Timer variables
const DURATION := 10 * 60 # 10 minutes in seconds
var remaining_time: float = DURATION

# --- Pop-up Shop ---
func _ready() -> void:
	main.visible = true
	shopui.visible = false
	countdown_label.text = _format_time(int(remaining_time))
	
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

# --- Settings Ui ---

func _ready_setting():
	settings.visible = false
	main.visible = true
	
func _on_backk_button_down() -> void:
	settings.visible = false
	
func _on_settings_button_down() -> void:
	settings.visible = true
	
func _on_back_setting_pressed() -> void:
	_ready_setting()

# --- Pop-up Profile ---

func _ready_profile():
	profile.visible = false
	main.visible = true
	
func _on_back_profile_button_down() -> void:
	profile.visible = false
	
func _on_profile_button_down() -> void:
	profile.visible = true
	
func _on_back_profile_pressed() -> void:
	_ready_profile()

# --- Pop-up Inventory ---

func _ready_inventory():
	inventory.visible = false
	main.visible = true
	
func _on_inventory_button_down() -> void:
	inventory.visible = true
	
func _on_back_inventory_button_down() -> void:
	inventory.visible = false
	
func _on_back_inventory_pressed() -> void:
	_ready_inventory()

# --- Pop-up Leaderboards ---

func _ready_leaderboards():
	leaderboards.visible = false
	main.visible = true
	
func _on_leaderboards_button_down() -> void:
	leaderboards.visible = true
	
func _on_back_leaderboards_button_down() -> void:
	leaderboards.visible = false
	
func _on_back_leaderboards_pressed() -> void:
	_ready_leaderboards()
