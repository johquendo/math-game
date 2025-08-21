extends Control

@onready var password_field = $LoginContainer/InputContainer/Password
@onready var username_field = $LoginContainer/InputContainer/Username
@onready var warning_text = $WarningText
@onready var login_button = $LoginContainer/ButtonContainer/Login
@onready var signup_button = $LoginContainer/ButtonContainer/Signup
@onready var login_text = $LoginText
@onready var transition = $Transition
@onready var button_sfx: AudioStreamPlayer = $Button_SFX

#Gets the config file
var is_signing_up := false
var config := ConfigFile.new()
var FILE_PATH := "user://players.cfg"	

#Chekcs if file exist 
func _ready():
	var err = config.load(FILE_PATH)
	if err != OK:
		print("No config file found, creating new one.")
		config.save(FILE_PATH)
	password_field.secret = true
	transition.play("fade_in")

#Toggles between login and sign up mode
func _on_signup_button_down():
	is_signing_up = !is_signing_up
	if is_signing_up:
		login_button.text = "Create"
		signup_button.text = "Cancel"
		login_text.bbcode_text = "Sign up"
	else:
		login_button.text = "Login"
		signup_button.text = "Sign Up"
		login_text.bbcode_text = "Login"
	username_field.text = ""
	password_field.text = ""
	warning_text.bbcode_text = " "

#Controls the sign-up and login
func _on_login_button_down():
	var username = username_field.text.strip_edges().to_upper()
	var password = password_field.text

	if username == "" or password == "":
		warning_text.bbcode_text = "[color=red]Fields cannot be empty.[/color]"
		return

	if is_signing_up:#Check if acc exist if not saves the data
		if config.has_section_key("users", username):
			warning_text.bbcode_text = "[color=red]Username already exists.[/color]"
			return
		config.set_value("users", username, password.sha256_text())
		config.save(FILE_PATH)
		warning_text.bbcode_text = "[color=green]Account created![/color]"
		_on_signup_button_down()
	else:#Checks if acc if in config file
		if !config.has_section_key("users", username):
			warning_text.bbcode_text = "[color=red]No account found.[/color]"
			return
		
		#Checks if inputed password matches the one under the user
		var saved_hash = config.get_value("users", username)
		if saved_hash == password.sha256_text():
			if button_sfx:
				button_sfx.play()
			warning_text.bbcode_text = "[color=green]Login successful![/color]"

			# Save current user to session
			config.set_value("session", "last_user", username)
			config.save(FILE_PATH)

			# Transition to main menu
			transition.play("fade_out")
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file("res://scenes/Whole game/main_menu.tscn")
		else:
			warning_text.bbcode_text = "[color=red]Incorrect password.[/color]"

	#Resets the lineEdit nodes
	username_field.text = ""
	password_field.text = ""


	








		
