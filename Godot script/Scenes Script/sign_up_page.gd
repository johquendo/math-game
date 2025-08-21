extends Control

@onready var username_field: LineEdit = $LogInContainer/InputContainer/Username
@onready var email_field: LineEdit = $LogInContainer/InputContainer/Email
@onready var password_field: LineEdit = $LogInContainer/InputContainer/Password
@onready var confirm_field: LineEdit = $LogInContainer/InputContainer/PasswordConfirmation
@onready var create_button: Button = $LogInContainer/InputContainer/CreateAccountBut
@onready var signup_text: Label = $LogInContainer/InputContainer/SignUpText

var config := ConfigFile.new()
const FILE_PATH := "user://players.cfg"

func _ready():
	# Hide password characters
	if password_field: password_field.secret_mode_enabled = true
	if confirm_field: confirm_field.secret_mode_enabled = true

	var err = config.load(FILE_PATH)
	if err != OK:
		print("No config file found, creating new one.")
		config.save(FILE_PATH)

func _on_CreateAccountBut_pressed():
	var username = username_field.text.strip_edges().to_upper()
	var email = email_field.text.strip_edges()
	var password = password_field.text
	var confirm = confirm_field.text

	if username.is_empty() or email.is_empty() or password.is_empty() or confirm.is_empty():
		signup_text.text = "All fields are required."
		return

	if password != confirm:
		signup_text.text = "Passwords do not match."
		return

	if config.has_section_key("users", username):
		signup_text.text = "Username already exists."
		return

	# Save new user
	config.set_value("users", username, password.sha256_text())
	var err = config.save(FILE_PATH)
	if err != OK:
		signup_text.text = "Failed to save account."
		return

	signup_text.text = "Account created! Returning to login..."
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://Scenes/log_in_page.tscn")
