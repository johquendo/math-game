extends Control

signal tool_changed(new_tool)
signal pen_tool_selected()  # NEW: Signal for pen tool
signal text_tool_selected()  # NEW: Signal for text tool

enum Tool { PEN, TEXT }
var current_tool = Tool.PEN
var drawing = false
var last_mouse_pos = Vector2()
var lines = []  # Store drawn lines

# Text tool variables
var text_instances = []  # Store text instances
var active_text_instance = null
var text_scene = preload("res://Scenes/TextTool.tscn")
var just_finished_editing = false

@onready var drawing_layer = $DrawingLayer
@onready var background = $Background
@onready var ui_tools = $UITools
@onready var pen_tool_button = $UITools/PenToolButton
@onready var text_tool_button = $UITools/TextToolButton

func _ready():
	# Set up background - make sure it's behind everything
	background.color = Color.WHITE
	background.size = get_viewport_rect().size

	# Make sure drawing layer is above background and can receive input
	drawing_layer.z_index = 1
	background.z_index = -1  # Really behind everything
	background.mouse_filter = MOUSE_FILTER_IGNORE  # Don't block input

	# Connect tool buttons
	pen_tool_button.pressed.connect(_on_pen_tool_selected)
	text_tool_button.pressed.connect(_on_text_tool_selected)

	# Make sure we can receive input
	mouse_filter = MOUSE_FILTER_STOP

func _on_pen_tool_selected():
	current_tool = Tool.PEN
	if active_text_instance:
		active_text_instance.finish_editing()
	active_text_instance = null
	
	# Set all text instances to ignore mouse events in pen mode
	for text_instance in text_instances:
		text_instance.set_pen_mode(true)
		
	emit_signal("tool_changed", current_tool)
	emit_signal("pen_tool_selected")  # NEW: Emit signal
	queue_redraw()

func _on_text_tool_selected():
	current_tool = Tool.TEXT
	if active_text_instance:
		active_text_instance.finish_editing()
	active_text_instance = null
	
	# Set all text instances to accept mouse events in text mode
	for text_instance in text_instances:
		text_instance.set_pen_mode(false)
		
	emit_signal("tool_changed", current_tool)
	emit_signal("text_tool_selected")  # NEW: Emit signal
	queue_redraw()

func _input(event):
	# Reset the just_finished_editing flag after processing
	if just_finished_editing:
		just_finished_editing = false
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if we're clicking on UI tools (buttons)
			var clicked_on_ui = false
			if pen_tool_button.get_global_rect().has_point(event.position):
				clicked_on_ui = true
			if text_tool_button.get_global_rect().has_point(event.position):
				clicked_on_ui = true

			if clicked_on_ui:
				# Deselect any active text when clicking UI buttons
				if active_text_instance:
					active_text_instance.finish_editing()
					active_text_instance = null
				return  # Don't create text if clicking on UI

			if current_tool == Tool.TEXT:
				# First, check if any context menu is visible and handle clicks outside
				var context_menu_was_visible = false
				for text_instance in text_instances:
					if text_instance.context_menu_visible:
						context_menu_was_visible = true
						# Check if clicking outside the context menu
						var menu_rect = Rect2(text_instance.context_menu.position, text_instance.context_menu.size)
						if not menu_rect.has_point(event.global_position):
							text_instance.hide_context_menu()
						else:
							# Clicking on the context menu itself, do nothing
							return
						break

				# If we just closed a context menu, don't create a new text box
				if context_menu_was_visible:
					return

				# Check if we're clicking on an existing text box
				var clicked_on_text = false
				for text_instance in text_instances:
					if text_instance.get_global_rect().has_point(event.position):
						clicked_on_text = true
						break

				if clicked_on_text:
					# Clicked on existing text box, do nothing
					return

				# Deselect active text if clicking outside
				if active_text_instance and not active_text_instance.get_global_rect().has_point(event.position):
					active_text_instance.finish_editing()
					active_text_instance = null
					just_finished_editing = true
					return

				# Only add text if no text box is currently active AND click is within canvas bounds
				if active_text_instance == null:
					# Convert global mouse position to local whiteboard position
					var local_mouse_pos = get_global_mouse_position() - global_position

					# ONLY create text if clicking within the canvas area
					if _is_within_canvas_bounds(local_mouse_pos):
						# Add text at corrected mouse position (adjusted to keep text box within bounds)
						add_text(_adjust_text_position(local_mouse_pos))

		# Handle right-click for all tools
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if current_tool == Tool.PEN:
				# For pen tool, right-click does nothing
				get_viewport().set_input_as_handled()
			elif current_tool == Tool.TEXT:
				# For text tool, handle right-click context menus
				handle_right_click_text_tool(event.position)

func handle_right_click_text_tool(click_position):
	# Check if we're right-clicking on a text box
	var clicked_on_text = null
	for text_instance in text_instances:
		if text_instance.get_global_rect().has_point(click_position) and not text_instance.is_editing:
			clicked_on_text = text_instance
			break

	# Hide all context menus first
	for text_instance in text_instances:
		text_instance.hide_context_menu()

	# Show context menu for the clicked text box
	if clicked_on_text:
		clicked_on_text.show_context_menu()

	get_viewport().set_input_as_handled()

func _is_text_blocking_input(position: Vector2) -> bool:
	# Check if we're clicking on a text instance that should block input
	for text_instance in text_instances:
		if text_instance.get_global_rect().has_point(position):
			# Only block if we're in pen mode and the text is not being edited
			if current_tool == Tool.PEN and not text_instance.is_editing:
				return true
	return false

func _gui_input(event):
	# Only process events within whiteboard bounds
	if not _is_within_drawing_bounds(event.position):
		return  # Ignore events outside whiteboard
		
	# Check if a text box is blocking input in pen mode
	if current_tool == Tool.PEN and _is_text_blocking_input(event.position):
		return  # Let the event pass through to the whiteboard

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if current_tool == Tool.PEN:
				drawing = event.pressed
				if drawing:
					last_mouse_pos = event.position
					# Start a new line
					lines.append([])
					lines[-1].append(event.position)

	if event is InputEventMouseMotion and drawing:
		if current_tool == Tool.PEN:
			# Only draw if within bounds
			if _is_within_drawing_bounds(event.position):
				lines[-1].append(event.position)
				queue_redraw()

func _is_within_drawing_bounds(position):
	# Get the drawing area bounds (excluding UI tools area)
	var drawing_bounds = Rect2(Vector2.ZERO, size)

	# If you have UI tools at the top, exclude that area
	var ui_tools_height = 0
	if has_node("UITools"):
		ui_tools_height = $UITools.size.y
		drawing_bounds = Rect2(Vector2(0, ui_tools_height), Vector2(size.x, size.y - ui_tools_height))

	return drawing_bounds.has_point(position)

func _is_within_canvas_bounds(position):
	# Check if position is within the entire canvas area (including UI tools)
	var canvas_bounds = Rect2(Vector2.ZERO, size)
	return canvas_bounds.has_point(position)

func _adjust_text_position(mouse_position):
	# Get the default text box size (from the scene or use a default)
	var text_box_size = Vector2(150, 30)  # Default size, adjust if your text boxes are different

	# Get canvas bounds (excluding UI tools area)
	var canvas_bounds = Rect2(Vector2.ZERO, size)
	var ui_tools_height = 0
	if has_node("UITools"):
		ui_tools_height = $UITools.size.y
		canvas_bounds = Rect2(Vector2(0, ui_tools_height), Vector2(size.x, size.y - ui_tools_height))

	# Adjust position to keep the entire text box within bounds
	var adjusted_position = mouse_position

	# Check right boundary
	if mouse_position.x + text_box_size.x > canvas_bounds.end.x:
		adjusted_position.x = canvas_bounds.end.x - text_box_size.x

	# Check left boundary
	if mouse_position.x < canvas_bounds.position.x:
		adjusted_position.x = canvas_bounds.position.x

	# Check bottom boundary
	if mouse_position.y + text_box_size.y > canvas_bounds.end.y:
		adjusted_position.y = canvas_bounds.end.y - text_box_size.y

	# Check top boundary (below UI tools)
	if mouse_position.y < canvas_bounds.position.y:
		adjusted_position.y = canvas_bounds.position.y

	return adjusted_position

func _draw():
	# Draw all lines (only within bounds)
	for line in lines:
		if line.size() > 1:
			for i in range(line.size() - 1):
				# Only draw if both points are within bounds
				if _is_within_drawing_bounds(line[i]) and _is_within_drawing_bounds(line[i+1]):
					draw_line(line[i], line[i+1], Color.BLACK, 2.0)

	# Draw borders for text boxes in text mode
	if current_tool == Tool.TEXT:
		for text_instance in text_instances:
			if not text_instance.is_editing:
				# Draw gray border around each text box in text mode
				var rect = Rect2(text_instance.position, text_instance.size)
				draw_rect(rect, Color.GRAY, false, 1.0)

func add_text(position):
	var new_text = text_scene.instantiate()
	drawing_layer.add_child(new_text)

	# Make sure text box doesn't overlap with UI tools
	var ui_rect = ui_tools.get_global_rect()
	if ui_rect.has_point(position):
		position.y = ui_rect.end.y + 20

	# Get the actual text box size after instantiation
	var text_box_size = new_text.size

	# Final adjustment to ensure text box stays within bounds
	var canvas_bounds = Rect2(Vector2.ZERO, size)
	var ui_tools_height = 0
	if has_node("UITools"):
		ui_tools_height = $UITools.size.y
		canvas_bounds = Rect2(Vector2(0, ui_tools_height), Vector2(size.x, size.y - ui_tools_height))

	# Check right boundary
	if position.x + text_box_size.x > canvas_bounds.end.x:
		position.x = canvas_bounds.end.x - text_box_size.x

	# Check bottom boundary
	if position.y + text_box_size.y > canvas_bounds.end.y:
		position.y = canvas_bounds.end.y - text_box_size.y

	new_text.position = position

	# Set initial mouse filter based on current tool
	if current_tool == Tool.PEN:
		new_text.set_pen_mode(true)
	else:
		new_text.set_pen_mode(false)

	# SAFELY connect signals
	if has_method("_on_text_size_changed"):
		new_text.text_size_changed.connect(_on_text_size_changed)
	if has_method("_on_text_edit_requested"):
		new_text.edit_requested.connect(_on_text_edit_requested)
	if has_method("_on_text_edit_finished"):
		new_text.edit_finished.connect(_on_text_edit_finished)

	text_instances.append(new_text)

	# Deselect any previously active text
	if active_text_instance:
		active_text_instance.finish_editing()

	active_text_instance = new_text
	# Start editing immediately
	new_text.start_editing()

func _on_text_size_changed(text_instance):
	# Adjust other elements if needed
	pass

func _on_text_edit_requested(text_instance):
	# Deselect any previously active text
	if active_text_instance and active_text_instance != text_instance:
		active_text_instance.finish_editing()

	active_text_instance = text_instance
	queue_redraw()

func _on_text_edit_finished(text_instance):
	if active_text_instance == text_instance:
		active_text_instance = null
	queue_redraw()

func get_current_tool():
	return current_tool

func has_active_text_instance():
	return active_text_instance != null

func safely_finish_editing():
	if active_text_instance:
		active_text_instance.finish_editing()
		active_text_instance = null
		queue_redraw()
