extends Node
class_name ShopRestockSystem

signal restocked(items_available: Array)

@export var restock_interval_minutes: float = 10.0

@export_category("Item Definitions")
@export var common_items: Array[String] = ["Addition", "Subtraction"]
@export var uncommon_items: Array[String] = ["Multiplication", "Division"]
@export var rare_items: Array[String] = ["Polynomials"]
@export var common_stock_min: int = 2
@export var common_stock_max: int = 4
@export var uncommon_stock_min: int = 1
@export var uncommon_stock_max: int = 2
@export var rare_stock_min: int = 1
@export var rare_stock_max: int = 1

var item_counts: Dictionary = {
	"Addition": 0,
	"Subtraction": 0,
	"Multiplication": 0,
	"Division": 0,
	"Polynomials": 0
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
	
	# Common items (always restock some)
	for common_item in common_items:
		var stock_amount = randi_range(common_stock_min, common_stock_max)
		item_counts[common_item] = stock_amount
		if stock_amount > 0:
			print("Restocked: ", common_item, " (x", stock_amount, ")")
	
	# Uncommon items (70% chance for each)
	for uncommon_item in uncommon_items:
		if randf() <= 0.7:
			var stock_amount = randi_range(uncommon_stock_min, uncommon_stock_max)
			item_counts[uncommon_item] = stock_amount
			print("Restocked: ", uncommon_item, " (x", stock_amount, ")")
		else:
			print("Skipped: ", uncommon_item, " (not restocked)")
	
	# Rare items (40% chance for each)
	for rare_item in rare_items:
		if randf() <= 0.4:
			var stock_amount = randi_range(rare_stock_min, rare_stock_max)
			item_counts[rare_item] = stock_amount
			print("Restocked: ", rare_item, " (x", stock_amount, ")")
		else:
			print("Skipped: ", rare_item, " (not restocked)")
	
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

func buy_item(item_name: String) -> bool:
	if item_counts.get(item_name, 0) > 0:
		item_counts[item_name] -= 1
		print("Purchased: ", item_name)
		print("Remaining: ", item_name, " (x", item_counts[item_name], ")")
		return true
	return false

func get_time_until_next_restock() -> float:
	return restock_timer.time_left

func get_item_rarity(item_name: String) -> String:
	if common_items.has(item_name):
		return "common"
	elif uncommon_items.has(item_name):
		return "uncommon"
	elif rare_items.has(item_name):
		return "rare"
	return "unknown"

func get_difficulty_for_problem(problem_type: String) -> int:
	match problem_type:
		"Addition", "Subtraction":
			return 0  # COMMON
		"Multiplication", "Division":
			return 1  # UNCOMMON
		"Polynomials":
			return 2  # RARE
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
	restock_timer.wait_time = minutes * 60
	restock_timer.start()
