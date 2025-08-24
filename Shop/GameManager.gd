extends Node

# Use relative paths or search for nodes
@onready var shop_system = get_node_or_null("../ShopRestockSystem")
@onready var problem_generator = get_node_or_null("../ProblemGenerator")

# UI elements - search recursively if needed
@onready var timer_label = _find_node_recursive("TimerLabel")
@onready var status_label = _find_node_recursive("StatusLabel")
@onready var stock_label = _find_node_recursive("StockLabel")
@onready var basic_math_button = _find_node_recursive("BuyCommon")

var timer_update_interval = 1.0
var timer_update_counter = 0.0

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

func _ready():
	print("GameManager starting...")
	print("Current scene: ", get_tree().current_scene.name)
	
	# Debug: Print all nodes to find what's available
	_print_node_tree(get_tree().root, 0)
	
	# Check if nodes were found
	if shop_system:
		if shop_system.has_signal("restocked"):
			shop_system.restocked.connect(_on_shop_restocked)
			print("Shop system connected!")
		else:
			print("Warning: ShopRestockSystem doesn't have restocked signal!")
	else:
		print("Warning: ShopRestockSystem not found!")
	
	if problem_generator:
		print("Problem generator connected!")
	else:
		print("Warning: ProblemGenerator not found!")
	
	# Check UI elements
	if timer_label:
		print("TimerLabel found: ", timer_label.get_path())
	else:
		print("Warning: TimerLabel not found!")
	
	if status_label:
		print("StatusLabel found: ", status_label.get_path())
	else:
		print("Warning: StatusLabel not found!")
	
	if stock_label:
		print("StockLabel found: ", stock_label.get_path())
	else:
		print("Warning: StockLabel not found!")
	
	if basic_math_button:
		print("BuyCommon button found: ", basic_math_button.get_path())
	else:
		print("Warning: BuyCommon button not found!")
	
	# Connect buttons
	_setup_button_connections()
	
	# Initial UI update
	update_inventory_display()
	update_timer_display()
	
	print("Game Manager ready!")

# Debug function to print node tree
func _print_node_tree(node: Node, depth: int):
	var indent = "  ".repeat(depth)
	print(indent + "├─ " + node.name + " (" + node.get_class() + ")")
	
	for child in node.get_children():
		_print_node_tree(child, depth + 1)

func _setup_button_connections():
	if basic_math_button and basic_math_button.has_signal("pressed"):
		basic_math_button.pressed.connect(test_buy_basic_math)
		print("BuyCommon button connected!")
	else:
		print("Warning: BuyCommon button not available for connection!")

func _process(delta):
	# Update timer display every second
	timer_update_counter += delta
	if timer_update_counter >= timer_update_interval:
		timer_update_counter = 0.0
		update_timer_display()

func _on_shop_restocked(_items: Array):
	print("Shop restocked signal received!")
	update_inventory_display()
	update_timer_display()
	
	if status_label:
		status_label.text = "Shop restocked!"

func update_inventory_display():
	# Update the stock display for Basic Math
	_update_basic_math_display()

func _update_basic_math_display():
	if not shop_system:
		return
	
	# Update Basic Math stock display
	var basic_math_count = shop_system.get_item_count("Basic Math")
	
	if stock_label:
		stock_label.text = "Stock: %d" % basic_math_count
	else:
		print("StockLabel not available for update!")
	
	# Update button state
	if basic_math_button:
		basic_math_button.disabled = (basic_math_count <= 0)
		if basic_math_count <= 0:
			basic_math_button.modulate = Color.GRAY
		else:
			basic_math_button.modulate = Color.WHITE

func update_timer_display():
	if shop_system and timer_label:
		var time_left = shop_system.get_time_until_next_restock()
		var minutes = floor(time_left / 60)
		var seconds = int(time_left) % 60
		timer_label.text = "Next restock: %d:%02d" % [minutes, seconds]
	elif not shop_system:
		print("Shop system not available for timer update!")
	elif not timer_label:
		print("TimerLabel not available for update!")
		
# Function called when player buys a problem from shop
func on_buy_problem(problem_type: String):
	if not shop_system:
		return {"success": false, "error": "Shop system not available"}
	
	var purchase_result = shop_system.buy_item(problem_type)
	
	if purchase_result.success:
		# Get the difficulty for this problem type
		var difficulty = shop_system.get_difficulty_for_problem(problem_type)
		
		# Set the problem generator to this difficulty and generate
		if problem_generator:
			# ProblemGenerator might not have set_difficulty, so we need to check
			if problem_generator.has_method("set_difficulty"):
				problem_generator.set_difficulty(difficulty)
			
			var problem_data = problem_generator.generate_item()
			
			# Get remaining count for display
			var remaining_count = shop_system.get_item_count(problem_type)
			
			# Update UI immediately
			update_inventory_display()
			
			if status_label:
				status_label.text = "Purchased: %s (%d left)" % [problem_type, remaining_count]
			
			# Return the purchase data including the answer
			var result = {
				"success": true,
				"item": problem_type,
				"remaining": remaining_count,
				"problem": problem_data["problem"],
				"answer": problem_data["answer"],
				"difficulty": difficulty
			}
			
			return result
		else:
			print("Problem generator not available")
			return {"success": false, "error": "Problem generator not available"}
	else:
		if status_label:
			status_label.text = "Cannot purchase: %s (out of stock)" % problem_type
		return {"success": false, "error": "Item not available"}

# Manual test functions
func test_buy_basic_math():
	return on_buy_problem("Basic Math")

# Manual restock for testing
func test_manual_restock():
	if shop_system:
		shop_system.manual_restock()
		if status_label:
			status_label.text = "Manual restock triggered!"
		print("Manual restock triggered!")
