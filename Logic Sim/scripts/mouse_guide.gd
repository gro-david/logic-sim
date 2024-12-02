extends Node2D

func _input(_event: InputEvent) -> void:
	$horizontal.global_position.y = get_global_mouse_position().y
	$vertical.global_position.x = get_global_mouse_position().x
