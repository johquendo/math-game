extends Control

@onready var username_field: LineEdit = $LogInContainer/InputContainer/Username
@onready var password_field: LineEdit = $LogInContainer/InputContainer/Password
@onready var login_button: Button = $LogInContainer/InputContainer/LogInButton
@onready var login_text: Label = $LogInContainer/InputContainer/LogInText
@onready var sign_up_button: Button = $LogInContainer/InputContainer/SignUpButton

var config := ConfigFile.new()
const FILE_PATH := "user://players.cfg"

func _ready():
	# Check if password field exists
	if password_field == null:
		push_error("Password field is null — check node path.")
		return
	
	# Enable password masking
	password_field.secret = true

	# Load or create config file
	var err = config.load(FILE_PATH)
	if err != OK:
		print("No config file found. Creating a new one.")
		config.save(FILE_PATH)

	# Connect signals (if not connected in editor)
	login_button.pressed.connect(_on_login_button_pressed)
	sign_up_button.pressed.connect(_on_sign_up_button_pressed)
	username_field.focus_entered.connect(_on_username_focus)
	password_field.focus_entered.connect(_on_password_focus)

func _on_username_focus():
	username_field.clear()

func _on_password_focus():
	password_field.clear()

func _on_login_button_pressed():
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
		await get_tree().create_timer(0.5).timeout  # Short delay before changing scene
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	else:
		login_text.text = "Incorrect password."

func _on_sign_up_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/sign_up_page.tscn")
