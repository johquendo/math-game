extends Control

@onready var username_field = $Background/LogInContainer/InputContainer/Username
@onready var password_field = $Background/LogInContainer/InputContainer/Password
@onready var email_field = $MainBackground/LogInContainer/InputContainer/Email
@onready var create_account_button = $MainBackground/LogInContainer/InputContainer/CreateAccountButton
@onready var password_confirmation = $MainBackground/LogInContainer/InputContainer/PasswordConfirmation



func _on_create_account_button_pressed() -> void:
	
