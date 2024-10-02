extends Area2D

@export var modulate_color: Color

var first_corner: Vector2 = Vector2.ZERO
var second_corner: Vector2 = Vector2.ZERO
var selected_areas: Array[Area2D] = []

func _unhandled_input(_event: InputEvent) -> void:
	if Global.edit_wires: return
	selection()
	delete()

func selection():
	if Input.is_action_pressed('mouse_click') and Input.is_action_pressed('ctrl'):
		if first_corner == Vector2.ZERO:
			first_corner = get_global_mouse_position()
			for area in selected_areas:
				area.get_parent().modulate = Color('ffffff')
			selected_areas.clear()
		second_corner = get_global_mouse_position()
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_released('mouse_click'):
		first_corner = Vector2.ZERO
		second_corner = Vector2.ZERO
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed('mouse_click'):
		for area in selected_areas:
			if not is_instance_valid(area): continue
			area.get_parent().modulate = Color('ffffff')
		selected_areas.clear()
	$collision_shape/Sprite2D.scale = abs(second_corner - first_corner) / Vector2(17, 17)
	$collision_shape.shape.size = abs(second_corner - first_corner)
	$collision_shape.global_position = first_corner + (second_corner - first_corner) / 2
	for area in selected_areas:
		if not area: continue
		area.get_parent().modulate = modulate_color

func delete():
	if not Input.is_action_just_pressed('delete'): return
	get_viewport().set_input_as_handled()
	for area in selected_areas:
		area.get_parent().queue_free()
	selected_areas.clear()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group('terminal_area'): return
	if area.is_in_group('terminal_placement_area'): return
	selected_areas.append(area)
