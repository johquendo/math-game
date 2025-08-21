extends Control

@onready var username_field: LineEdit = $LogInContainer/InputContainer/Username
@onready var password_field: LineEdit = $LogInContainer/InputContainer/Password
@onready var login_button: Button = $LogInContainer/InputContainer/LogInButton
@onready var signup_button: Button = $LogInContainer/InputContainer/SignUpButton
@onready var login_text: Label = $LogInContainer/InputContainer/LogInText

var config := ConfigFile.new()
const FILE_PATH := "user://players.cfg"

func _ready():
	# Confirm node types to avoid runtime errors
	assert(password_field is LineEdit)
	assert(username_field is LineEdit)

	# Enable password masking
	password_field.secret_mode_enabled = true

	# Load or create config file
	var err = config.load(FILE_PATH)
	if err != OK:
		print("No config file found, creating new one.")
		config.save(FILE_PATH)

func _on_LogInButton_pressed():
	var username = username_field.text.strip_edges().to_upper()
	var password = password_field.text

	if username.is_empty() or password.is_empty():
		login_text.text = "Fields cannot be empty."
		return

	if not config.has_section_key("users", username):
		login_text.text = "No account found."
		return

	var saved_hash = config.get_value("users", username)
	if saved_hash == password.sha256_text():
		login_text.text = "Login successful!"
		config.set_value("session", "last_user", username)
		config.save(FILE_PATH)
		get_tree().change_scene_to_file("res://scenes/Whole game/main_menu.tscn")
	else:
		login_text.text = "Incorrect password."

	username_field.clear()
	password_field.clear()

func _on_SignUpButton_pressed():
	get_tree().change_scene_to_file("res://scenes/signup.tscn")
