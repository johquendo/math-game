extends Control

@onready var left_panel = $HBoxContainer/LeftPanel
@onready var right_panel = $HBoxContainer/RightPanel
@onready var middle_container = $HBoxContainer/MiddleContainer
@onready var shop_panel = $HBoxContainer/middle_container/ShopPanel
@onready var shop_exit = $HBoxContainer/middle_container/ShopPanel/ShopButton
@onready var inventory_panel = $HBoxContainer/middle_container/InventoryPanel
@onready var leaderboards_panel = $HBoxContainer/MarginContainer/MarginContainer/VBoxContainer/LeaderboardsButton
@onready var settings_panel = $HBoxContainer/middle_container/SettingsPanel

var left_visible := true
var right_visible := true

func _on_left_button_pressed() -> void:
	left_visible = !left_visible
	left_panel.visible = left_visible

func _on_right_button_pressed() -> void:
	right_visible = !right_visible
	right_panel.visible = right_visible

func _on_shop_button_button_down() -> void:
	shop_panel.visible = true

func _on_shop_exit_button_down() -> void:
	shop_panel.visible = false

func _on_inventory_button_button_down() -> void:
	inventory_panel.visible = true
	
func _on_inventory_exit_button_down() -> void:
	inventory_panel.visible = false
	
func _on_leaderboards_button_button_down() -> void:
	leaderboards_panel.visible = true
	
func _on_leaderboards_exit_button_down() -> void:
	leaderboards_panel.visible = false

func _on_settings_button_button_down() -> void:
	settings_panel.visible = true
	
func _on_settings_exit_button_down() -> void:
	settings_panel.visible = false
