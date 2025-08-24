extends Node
class_name ShopRestockSystem

signal restocked(items_available: Array)

@export var restock_interval_minutes: float = 10.0

@export_category("Item Definitions")
@export var basic_math_items: Array[String] = ["Addition", "Subtraction"]  # Combined basic math
@export var basic_stock_min: int = 3
@export var basic_stock_max: int = 6

var item_counts: Dictionary = {
	"Basic Math": 0  # Only Basic Math now (combines Addition/Subtraction)
}

var restock_timer: Timer

func _ready():
	restock_shop()
	
	restock_timer = Timer.new()
	add_child(restock_timer)
	
	restock_timer.wait_time = restock_interval_minutes * 60
	restock_timer.one_shot = false
	restock_timer.timeout.connect(_on_restock_timer_timeout)
	
	restock_timer.start()
	
	print("Shop restock system started. First restock in ", restock_interval_minutes, " minutes")

func _on_restock_timer_timeout():
	restock_shop()

func restock_shop():
	# RESET ALL STOCK TO ZERO FIRST
	for item in item_counts:
		item_counts[item] = 0
	
	print("=== RESTOCKING SHOP ===")
	
	# Basic Math items (always restock some)
	var basic_stock_amount = randi_range(basic_stock_min, basic_stock_max)
	item_counts["Basic Math"] = basic_stock_amount
	print("Restocked: Basic Math (x", basic_stock_amount, ")")
	
	var available_items = get_current_items()
	print("Shop restocked! Inventory: ", get_inventory_string())
	print("======================")
	
	# EMIT SIGNAL AFTER EVERYTHING IS DONE
	restocked.emit(available_items)

func get_current_items():
	var items = []
	for item in item_counts:
		if item_counts[item] > 0:
			for i in range(item_counts[item]):
				items.append(item)
	return items

func get_item_count(item_name: String) -> int:
	return item_counts.get(item_name, 0)

func get_all_item_counts() -> Dictionary:
	return item_counts.duplicate()

func buy_item(item_name: String) -> Dictionary:
	if item_counts.get(item_name, 0) > 0:
		item_counts[item_name] -= 1
		print("Purchased: ", item_name)
		print("Remaining: ", item_name, " (x", item_counts[item_name], ")")
		
		# For Basic Math, randomly choose between Addition or Subtraction
		var actual_problem_type = ""
		if item_name == "Basic Math":
			actual_problem_type = basic_math_items[randi() % basic_math_items.size()]
			print("Randomly selected: ", actual_problem_type)
		else:
			actual_problem_type = item_name
		
		return {
			"success": true,
			"display_name": item_name,
			"actual_type": actual_problem_type,
			"remaining": item_counts[item_name]
		}
	
	return {"success": false}

func get_time_until_next_restock() -> float:
	if restock_timer:
		return restock_timer.time_left
	return 0.0

func get_item_rarity(_item_name: String) -> String:
	# All items are now common rarity
	return "common"

func get_difficulty_for_problem(_problem_type: String) -> int:
	# All problems are now common difficulty (0)
	return 0

func get_inventory_string() -> String:
	var result = []
	for item in item_counts:
		if item_counts[item] > 0:
			var rarity = get_item_rarity(item)
			result.append("%s: %d (%s)" % [item, item_counts[item], rarity])
	
	if result.is_empty():
		return "Empty"
	return ", ".join(result)

# Manual restock function for testing
func manual_restock():
	print("=== MANUAL RESTOCK TRIGGERED ===")
	restock_shop()  # This will emit the signal automatically

# Change restock interval dynamically
func set_restock_interval(minutes: float):
	restock_interval_minutes = minutes
	if restock_timer:
		restock_timer.wait_time = minutes * 60
		restock_timer.start()
