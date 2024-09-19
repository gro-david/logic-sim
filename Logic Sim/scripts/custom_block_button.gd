extends Button
class_name CustomBlockButton

signal instantiate_block
signal edit_block

var corresponding_block_data_path: String

var pressed_mouse_button: int


func _on_button_down() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		pressed_mouse_button = MOUSE_BUTTON_LEFT
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		pressed_mouse_button = MOUSE_BUTTON_RIGHT


func _on_pressed() -> void:
	if pressed_mouse_button == MOUSE_BUTTON_LEFT:
		instantiate_block.emit(corresponding_block_data_path)
	elif pressed_mouse_button == MOUSE_BUTTON_RIGHT:
		edit_block.emit(corresponding_block_data_path)
