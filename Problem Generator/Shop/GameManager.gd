extends Node

@onready var shop_system = get_node("/root/ShopScene/ShopRestockSystem")
@onready var problem_generator = get_node("/root/ShopScene/ProblemGenerator")

# UI elements for inventory display
@onready var inventory_container = get_node_or_null("/root/ShopScene/UI/InventoryContainer")
@onready var timer_label = get_node_or_null("/root/ShopScene/UI/TimerLabel")
@onready var status_label = get_node_or_null("/root/ShopScene/UI/StatusLabel")

var timer_update_interval = 1.0
var timer_update_counter = 0.0

func _ready():
	# Check if nodes were found
	if shop_system:
		shop_system.restocked.connect(_on_shop_restocked)
		print("Shop system connected!")
	else:
		print("Warning: ShopRestockSystem not found!")
	
	if problem_generator:
		print("Problem generator connected!")
	else:
		print("Warning: ProblemGenerator not found!")
	
	# Initial UI update
	update_inventory_display()
	update_timer_display()
	
	print("Game Manager ready!")

func _process(delta):
	# Update timer display every second
	timer_update_counter += delta
	if timer_update_counter >= timer_update_interval:
		timer_update_counter = 0.0
		update_timer_display()

func _on_shop_restocked(_items: Array):
	print("Shop restocked signal received!")
	update_inventory_display()  # MAKE SURE THIS LINE IS HERE
	update_timer_display()
	
	if status_label:
		status_label.text = "Shop restocked!"

func update_inventory_display():
	if not inventory_container:
		print("Inventory container not found!")
		return
	
	# Clear existing inventory labels
	for child in inventory_container.get_children():
		child.queue_free()
	
	# Create new inventory display
	var available_items = shop_system.get_current_items()
	var has_items = false
	
	# Create a temporary dictionary to count items
	var item_counts = {}
	for item in available_items:
		if item in item_counts:
			item_counts[item] += 1
		else:
			item_counts[item] = 1
	
	print("Updating inventory display with: ", item_counts)
	
	for item in item_counts:
		var count = item_counts[item]
		if count > 0:
			has_items = true
			var rarity = shop_system.get_item_rarity(item)
			create_inventory_label(item, count, rarity)
	
	if not has_items:
		var empty_label = Label.new()
		empty_label.text = "Inventory Empty"
		empty_label.add_theme_color_override("font_color", Color.GRAY)
		inventory_container.add_child(empty_label)

func create_inventory_label(item_name: String, count: int, rarity: String):
	var label = Label.new()
	
	# Set text and style based on rarity
	label.text = "%s: %d" % [item_name, count]
	
	match rarity:
		"common":
			label.add_theme_color_override("font_color", Color.WHITE)
		"uncommon":
			label.add_theme_color_override("font_color", Color.CYAN)
		"rare":
			label.add_theme_color_override("font_color", Color.GOLD)
		_:
			label.add_theme_color_override("font_color", Color.WHITE)
	
	inventory_container.add_child(label)

func update_timer_display():
	if shop_system and timer_label:
		var time_left = shop_system.get_time_until_next_restock()
		var minutes = floor(time_left / 60)
		var seconds = int(time_left) % 60
		timer_label.text = "Next restock: %d:%02d" % [minutes, seconds]

# Function called when player buys a problem from shop
func on_buy_problem(problem_type: String):
	var purchase_success = shop_system.buy_item(problem_type)
	
	if purchase_success:
		# Get the difficulty for this problem type
		var difficulty = shop_system.get_difficulty_for_problem(problem_type)
		
		# Set the problem generator to this difficulty and generate
		if problem_generator:
			problem_generator.set_difficulty(difficulty)
			var problem_data = problem_generator.generate_item()
			
			# Get remaining count for display
			var remaining_count = 0
			var available_items = shop_system.get_current_items()
			for item in available_items:
				if item == problem_type:
					remaining_count += 1
			
			# Update UI
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
func test_buy_addition():
	return on_buy_problem("Addition")

func test_buy_subtraction():
	return on_buy_problem("Subtraction")

func test_buy_multiplication():
	return on_buy_problem("Multiplication")

func test_buy_division():
	return on_buy_problem("Division")

func test_buy_polynomials():
	return on_buy_problem("Polynomials")

# Manual restock for testing
func test_manual_restock():
	if shop_system:
		shop_system.manual_restock()
		if status_label:
			status_label.text = "Manual restock triggered!"
		print("Manual restock triggered!")
