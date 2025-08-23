extends Control

var is_dragging = false
var drag_offset = Vector2()
var is_resizing = false
var resize_start = Vector2()
var original_size = Vector2()
var is_editing = false
var context_menu = null
var context_menu_visible = false
var resize_handle_size = 12
var current_tool_mode = 0  # 0 = PEN, 1 = TEXT

signal text_size_changed(text_instance)
signal edit_requested(text_instance)
signal edit_finished(text_instance)

@onready var text_edit = $TextEdit
@onready var resize_handle = $ResizeHandle

func _ready():
	# Initial setup
	custom_minimum_size = Vector2(150, 30)
	size = Vector2(150, 30)
	
	# Setup TextEdit
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	text_edit.size = size
	
	# Set text color to black and center alignment
	text_edit.add_theme_color_override("font_color", Color.BLACK)
	text_edit.add_theme_color_override("font_readonly_color", Color.DIM_GRAY)
	
	# Create centered alignment
	var font = text_edit.get_theme_font("font")
	if font:
		text_edit.add_theme_font_override("font", font)
		text_edit.add_theme_font_size_override("font_size", 16)  # Adjust font size as needed
	
	# Create a transparent background
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color.TRANSPARENT
	text_edit.add_theme_stylebox_override("normal", style_box)
	text_edit.add_theme_stylebox_override("focus", style_box)
	text_edit.add_theme_stylebox_override("read_only", style_box)
	
	# Setup resize handle
	resize_handle.size = Vector2(resize_handle_size, resize_handle_size)
	resize_handle.position = Vector2(size.x - resize_handle_size, size.y - resize_handle_size)
	resize_handle.color = Color.BLUE
	resize_handle.visible = false
	
	# Connect to main scene tool changes
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_signal("tool_changed"):
		main_scene.tool_changed.connect(_on_tool_changed)
	
	# Connect signals
	text_edit.text_changed.connect(_on_self_text_changed)
	text_edit.focus_exited.connect(_on_text_edit_focus_exited)
	resize_handle.gui_input.connect(_on_resize_handle_gui_input)
	text_edit.gui_input.connect(_on_text_edit_gui_input)
	
	# Make sure we can receive input
	mouse_filter = MOUSE_FILTER_STOP
	text_edit.mouse_filter = MOUSE_FILTER_STOP
	
	# Create context menu
	create_context_menu()
	
	# Initially not editable
	finish_editing()
	
	# Center the text initially
	center_text()

func center_text():
	# Center align the text by adjusting content margins
	text_edit.add_theme_constant_override("line_spacing", 4)  # Add some spacing
	
	# For Godot 4, we need to use a different approach for text alignment
	# We'll use a rich text label effect or custom drawing
	text_edit.scroll_vertical = 0  # Start at top
	text_edit.scroll_horizontal = 0  # Start at left
	
	# If you want true centering, you might need to use RichTextLabel instead
	# But for now, we'll adjust the text positioning

func _on_tool_changed(new_tool):
	current_tool_mode = new_tool
	queue_redraw()  # Redraw to update border visibility

func _on_self_text_changed():
	# Auto-resize height based on content
	emit_signal("text_size_changed", self)
	# Re-center text when content changes
	center_text()

func _on_text_edit_focus_exited():
	# When text edit loses focus, finish editing
	if is_editing:
		finish_editing()

func _gui_input(event):
	# Handle right-click for context menu
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if not is_editing:
				show_context_menu()
				get_viewport().set_input_as_handled()

func _on_text_edit_gui_input(event):
	if not is_editing:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Start dragging when clicking on text edit (but not on resize handle)
			var local_pos = event.position
			var resize_handle_rect = Rect2(resize_handle.position, resize_handle.size)
			
			if not resize_handle_rect.has_point(local_pos):
				is_dragging = true
				drag_offset = event.global_position - global_position
				get_viewport().set_input_as_handled()
		
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_dragging = false
	
	if event is InputEventMouseMotion and is_dragging:
		global_position = event.global_position - drag_offset
		get_viewport().set_input_as_handled()

func _on_resize_handle_gui_input(event):
	if not is_editing:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			is_resizing = true
			resize_start = event.global_position
			original_size = size
			get_viewport().set_input_as_handled()
		
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			is_resizing = false
	
	if event is InputEventMouseMotion and is_resizing:
		var delta = event.global_position - resize_start
		
		# Calculate new size
		var new_size = Vector2(
			max(original_size.x + delta.x, custom_minimum_size.x),
			max(original_size.y + delta.y, custom_minimum_size.y)
		)
		
		# Apply new size
		size = new_size
		text_edit.size = new_size
		resize_handle.position = Vector2(size.x - resize_handle_size, size.y - resize_handle_size)
		resize_start = event.global_position
		original_size = size
		queue_redraw()
		get_viewport().set_input_as_handled()

func create_context_menu():
	context_menu = PopupMenu.new()
	context_menu.add_item("Edit", 0)
	context_menu.set_size(Vector2(80, 30))
	context_menu.id_pressed.connect(_on_context_menu_id_pressed)
	context_menu.popup_hide.connect(_on_context_menu_hidden)
	add_child(context_menu)

func _on_context_menu_id_pressed(id):
	if id == 0:  # Edit
		request_edit()

func _on_context_menu_hidden():
	context_menu_visible = false

func show_context_menu():
	# Only show context menu if no text box is currently active
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.active_text_instance == null:
		context_menu.position = get_global_mouse_position()
		context_menu.popup()
		context_menu_visible = true

func hide_context_menu():
	context_menu.hide()
	context_menu_visible = false

func start_editing():
	is_editing = true
	# Enable editing
	text_edit.focus_mode = FOCUS_ALL
	text_edit.caret_blink = true
	text_edit.editable = true
	text_edit.grab_focus()
	resize_handle.visible = true
	mouse_default_cursor_shape = Control.CURSOR_IBEAM
	queue_redraw()  # Redraw to show border
	center_text()  # Re-center text when starting edit

func finish_editing():
	is_editing = false
	is_dragging = false
	is_resizing = false
	# Disable editing
	text_edit.focus_mode = FOCUS_NONE
	text_edit.caret_blink = false
	text_edit.editable = false
	resize_handle.visible = false
	mouse_default_cursor_shape = Control.CURSOR_ARROW
	emit_signal("edit_finished", self)
	queue_redraw()  # Redraw to update border
	center_text()  # Re-center text when finishing edit

func request_edit():
	if not is_editing:
		start_editing()
		emit_signal("edit_requested", self)

func _draw():
	# Draw border when editing OR when in text mode (but not editing)
	if is_editing:
		# Blue border when editing (regardless of tool mode)
		draw_rect(Rect2(Vector2.ZERO, size), Color.BLUE, false, 2.0)
	elif current_tool_mode == 1:  # 1 = TEXT mode (assuming PEN=0, TEXT=1)
		# Gray border when in text mode (but not editing)
		draw_rect(Rect2(Vector2.ZERO, size), Color.GRAY, false, 1.0)
	# No border when in pen mode and not editing
