extends Control

@onready var game_manager = get_node("/root/ShopScene/GameManager")

func _on_BuyAdditionButton_pressed():
	game_manager.test_buy_addition()

func _on_BuySubtractionButton_pressed():
	game_manager.test_buy_subtraction()

func _on_BuyMultiplicationButton_pressed():
	game_manager.test_buy_multiplication()

func _on_BuyDivisionButton_pressed():
	game_manager.test_buy_division()

func _on_BuyPolynomialsButton_pressed():
	game_manager.test_buy_polynomials()

func _on_TestRestockButton_pressed():
	game_manager.test_manual_restock()
