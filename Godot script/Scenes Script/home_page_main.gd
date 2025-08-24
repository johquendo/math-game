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

# Tool button references
@onready var pen_tool_button: Button = $BoardTools/PenToolButton
@onready var text_tool_button: Button = $BoardTools/TextToolButton

var whiteboard_scene = preload("res://Scenes/WhiteboardApp.tscn")
var whiteboard_instance = null
var whiteboard_layer = null

# Timer variables
const DURATION := 10 * 60 # 10 minutes in seconds
var remaining_time: float = DURATION

# --- Pop-up Shop ---
func _ready() -> void:
	main.visible = true
	shopui.visible = false
	countdown_label.text = _format_time(int(remaining_time))
	
	# Connect tool buttons
	if pen_tool_button:
		pen_tool_button.pressed.connect(_on_pen_tool_selected)
	if text_tool_button:
		text_tool_button.pressed.connect(_on_text_tool_selected)

# --- White Board Stuff ---

	call_deferred("_setup_whiteboard")

func _setup_whiteboard():
	# Create a dedicated canvas layer for the whiteboard
	whiteboard_layer = CanvasLayer.new()
	whiteboard_layer.layer = 10  # High layer number to be on top
	add_child(whiteboard_layer)

	# Instance the whiteboard
	whiteboard_instance = whiteboard_scene.instantiate()
	whiteboard_layer.add_child(whiteboard_instance)

	# POSITIONING: Set the whiteboard position and size
	whiteboard_instance.position = Vector2(221, 16)  # Adjust these values
	whiteboard_instance.size = Vector2(706, 608)    # Adjust these values

	# Ensure input works
	whiteboard_instance.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Connect to whiteboard signals if whiteboard instance exists
	if whiteboard_instance:
		if whiteboard_instance.has_signal("pen_tool_selected"):
			whiteboard_instance.pen_tool_selected.connect(_on_whiteboard_pen_tool_selected)
		if whiteboard_instance.has_signal("text_tool_selected"):
			whiteboard_instance.text_tool_selected.connect(_on_whiteboard_text_tool_selected)

# Tool selection functions that call whiteboard methods
func _on_pen_tool_selected():
	if whiteboard_instance:
		whiteboard_instance.call_deferred("_on_pen_tool_selected")

func _on_text_tool_selected():
	if whiteboard_instance:
		whiteboard_instance.call_deferred("_on_text_tool_selected")

# Signal handlers for whiteboard tool changes
func _on_whiteboard_pen_tool_selected():
	# Update button states to reflect current tool
	if pen_tool_button:
		pen_tool_button.button_pressed = true
	if text_tool_button:
		text_tool_button.button_pressed = false

func _on_whiteboard_text_tool_selected():
	# Update button states to reflect current tool
	if pen_tool_button:
		pen_tool_button.button_pressed = false
	if text_tool_button:
		text_tool_button.button_pressed = true

# --- end of whiteboard ---

# --- Button Handlers ---
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
