extends Node

signal show_terminal_names_changed

var wire_curve_direction_toggled: bool = true
var show_terminal_names: bool = false:
	set(value):
		show_terminal_names = value
		show_terminal_names_changed.emit()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed('toggle_wire_curve_direction'):
		wire_curve_direction_toggled = not wire_curve_direction_toggled
