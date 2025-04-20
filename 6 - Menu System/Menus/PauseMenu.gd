extends CanvasLayer

@onready var cursor: Cursor = get_parent()._cursor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/UnitsButton.grab_focus()
	
	##Disable the cursor
	cursor.hide()
	cursor.process_mode = Node.PROCESS_MODE_DISABLED

func _on_units_button_pressed() -> void:
	pass # Replace with function body.

func _on_options_button_pressed() -> void:
	pass # Replace with function body.

func _on_end_turn_button_pressed() -> void:
	pass # Replace with function body.

func _on_close_button_pressed() -> void:
	#Enable cursor and close menu
	cursor.process_mode = Node.PROCESS_MODE_INHERIT
	cursor.reset_cursor()
	cursor.show()
	queue_free()
