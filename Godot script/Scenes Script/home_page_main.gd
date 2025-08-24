extends Control

# UI references
@onready var control: Control = $"."  
@onready var main: VBoxContainer = $main
@onready var shopui: Panel = $shopui
@onready var countdown_label = _find_node_recursive("TimerLabel")

# Remove the timer variables - we'll use ShopRestockSystem's timer instead

# Helper function to find nodes by name recursively
func _find_node_recursive(node_name: String) -> Node:
	return _find_node_recursive_helper(get_tree().root, node_name)

func _find_node_recursive_helper(node: Node, node_name: String) -> Node:
	if node.name == node_name:
		return node
	
	for child in node.get_children():
		var result = _find_node_recursive_helper(child, node_name)
		if result:
			return result
	
	return null

# --- UI Logic ---
func _ready() -> void:
	main.visible = true
	shopui.visible = false
	
	# Don't set initial text here - GameManager will handle it
	if countdown_label:
		print("TimerLabel found at: ", countdown_label.get_path())
	else:
		print("Warning: TimerLabel not found!")
	
func _on_settings_pressed() -> void:
	main.visible = false
	shopui.visible = true

func _on_button_pressed() -> void:
	_ready()

func _on_shop_button_down() -> void:
	shopui.visible = true

func _on_back_button_down() -> void:
	shopui.visible = false

# REMOVE the _process function entirely - GameManager handles timer updates
