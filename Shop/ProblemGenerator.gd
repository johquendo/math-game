extends Control

# Difficulty levels
enum DIFFICULTY {COMMON, UNCOMMON, RARE}
var current_difficulty: DIFFICULTY = DIFFICULTY.COMMON

# Current item data
var current_item = {
	"type": "square",  # Visual representation
	"difficulty": DIFFICULTY.COMMON,
	"problem": "",     # Hidden problem text
	"answer": 0        # Hidden answer value
}

func _ready():
	# Print welcome message to output
	print("=== Math Problem Generator ===")
	print("Problems will appear here in the output console.")
	print("=====================================")
	
	# Generate first item
	generate_item()

# Public function to generate an item (can be called from other scripts)
func generate_item():
	var problem_data = {}
	
	match current_difficulty:
		DIFFICULTY.COMMON:
			problem_data = generate_common_problem()
			current_item.type = "square"
		DIFFICULTY.UNCOMMON:
			problem_data = generate_uncommon_problem()
			current_item.type = "circle"
		DIFFICULTY.RARE:
			problem_data = generate_rare_problem()
			current_item.type = "triangle"
	
	# Update current item with hidden problem data
	current_item.difficulty = current_difficulty
	current_item.problem = problem_data["problem"]
	current_item.answer = problem_data["answer"]
	
	# PRINT PROBLEM TO OUTPUT CONSOLE
	print_problem_to_console(problem_data["problem"], problem_data["answer"])
	
	return problem_data

# Public function to change difficulty (can be called from other scripts)
func set_difficulty(difficulty: int):
	# Cast the integer to the enum type to fix the warning
	current_difficulty = difficulty as DIFFICULTY
	generate_item()

func print_problem_to_console(problem, answer):
	# Get difficulty name for output
	var diff_name = ""
	match current_difficulty:
		DIFFICULTY.COMMON: diff_name = "COMMON"
		DIFFICULTY.UNCOMMON: diff_name = "UNCOMMON"
		DIFFICULTY.RARE: diff_name = "RARE"
	
	# Print to Godot's output console
	print("---")
	print("Generated %s Problem:" % diff_name)
	print("Problem: %s" % problem)
	print("Answer: %d" % answer)
	print("Visual Item: %s" % current_item.type)
	print("---")

# Function to get the current problem (for answering)
func get_current_problem():
	return current_item.problem

# Function to check answer against current item
func check_answer(user_answer):
	return user_answer == current_item.answer

# Problem generation functions
func generate_common_problem():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var num1 = rng.randi_range(1, 100)
	var num2 = rng.randi_range(1, 100)
	var operation = rng.randi_range(0, 1)
	
	var problem = ""
	var answer = 0
	
	if operation == 0:  # Addition
		problem = "%d + %d" % [num1, num2]
		answer = num1 + num2
	else:  # Subtraction
		if num1 < num2:
			var temp = num1
			num1 = num2
			num2 = temp
		problem = "%d - %d" % [num1, num2]
		answer = num1 - num2
	
	return {"problem": problem, "answer": answer}

func generate_uncommon_problem():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var num1 = rng.randi_range(1, 12)
	var num2 = rng.randi_range(1, 12)
	var operation = rng.randi_range(0, 1)
	
	var problem = ""
	var answer = 0
	
	if operation == 0:  # Multiplication
		problem = "%d × %d" % [num1, num2]
		answer = num1 * num2
	else:  # Division
		var product = num1 * num2
		problem = "%d ÷ %d" % [product, num1]
		answer = num2
	
	return {"problem": problem, "answer": answer}

func generate_rare_problem():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Only polynomial problems for rare
	var problem_type = rng.randi_range(0, 2)
	var problem = ""
	var answer = 0
	
	match problem_type:
		0:  # Simple polynomial evaluation
			var x = rng.randi_range(1, 5)
			var a = rng.randi_range(1, 5)
			var b = rng.randi_range(1, 10)
			var c = rng.randi_range(1, 20)
			problem = "Evaluate: %dx² + %dx + %d when x = %d" % [a, b, c, x]
			answer = a*x*x + b*x + c
		
		1:  # Polynomial addition
			var a1 = rng.randi_range(1, 5)
			var b1 = rng.randi_range(1, 10)
			var a2 = rng.randi_range(1, 5)
			var b2 = rng.randi_range(1, 10)
			problem = "Add: (%dx + %d) + (%dx + %d)" % [a1, b1, a2, b2]
			answer = a1 + a2  # Coefficient of x
		
		2:  # Polynomial multiplication (simple)
			var a = rng.randi_range(1, 3)
			var b = rng.randi_range(1, 5)
			problem = "Multiply: %d(x + %d)" % [a, b]
			answer = a * b  # Constant term after expansion
	
	return {"problem": problem, "answer": answer}
