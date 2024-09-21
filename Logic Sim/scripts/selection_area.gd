extends Area2D

@export var modulate_color: Color

var first_corner: Vector2 = Vector2.ZERO
var second_corner: Vector2 = Vector2.ZERO
var selected_areas: Array[Area2D] = []

func _unhandled_input(_event: InputEvent) -> void:
	get_viewport().set_input_as_handled()
	selection()
	delete()

func selection():
	if Input.is_action_pressed('mouse_click'):
		if first_corner == Vector2.ZERO:
			first_corner = get_global_mouse_position()
			for area in selected_areas:
				area.get_parent().modulate = Color('ffffff')
			selected_areas.clear()
		second_corner = get_global_mouse_position()
	elif Input.is_action_just_released('mouse_click'):
		first_corner = Vector2.ZERO
		second_corner = Vector2.ZERO
	$collision_shape/Sprite2D.scale = abs(second_corner - first_corner) / Vector2(17, 17)
	$collision_shape.shape.size = abs(second_corner - first_corner)
	$collision_shape.global_position = first_corner + (second_corner - first_corner) / 2
	for area in selected_areas:
		area.get_parent().modulate = modulate_color

func delete():
	if not Input.is_action_just_pressed('delete'): return
	for area in selected_areas:
		area.get_parent().queue_free()
	selected_areas.clear()
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group('terminal_area'): return
	selected_areas.append(area)
