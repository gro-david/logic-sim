extends Node

var wire_curve_direction_toggled: bool = true

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('toggle_wire_curve_direction'):
		wire_curve_direction_toggled = not wire_curve_direction_toggled
