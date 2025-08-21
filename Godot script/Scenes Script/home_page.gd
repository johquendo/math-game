extends Control

@onready var left_panel = $HBoxContainer/LeftPanel
@onready var right_panel = $HBoxContainer/RightPanel
@onready var middle_container = $HBoxContainer/MiddleContainer
@onready var shop_panel = $HBoxContainer/middle_container/ShopPanel

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
