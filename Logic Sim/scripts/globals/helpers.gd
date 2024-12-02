extends Node

func merge_dicts_recursively(a: Dictionary, b: Dictionary) -> Dictionary:
	if len(b.keys()) == 0: return a
	if a.has(b.keys()[0]):
		a[b.keys()[0]] = merge_dicts_recursively(a[b.keys()[0]], b[b.keys()[0]])
	else:
		a.merge(b)
	return a

func dict_key_to_int_recursively(dict: Dictionary) -> Dictionary:
	# Collect keys that need to be changed to avoid modifying the dictionary while iterating
	for key in dict.keys():
		var new_key = int(key)
		dict[new_key] = dict[key] # Assign the value to the new key
		dict.erase(key) # Remove the old key
		if typeof(dict[new_key]) == TYPE_DICTIONARY:
			dict_key_to_int_recursively(dict[new_key])

	return dict


func get_position_on_building_grid(position: Vector2) -> Vector2:
	return round(position / Global.building_grid_size) * Global.building_grid_size

func debug(node, line, msg):
	print("[%s, %s@%s] %s" % [node, node.get_script().get_path(), line, msg])

func terminal_sorting_helper_axis_x(a,b) -> bool:
	return a.global_position.x < b.global_position.x
func terminal_sorting_helper_axis_y(a,b) -> bool:
	return a.global_position.y < b.global_position.y
