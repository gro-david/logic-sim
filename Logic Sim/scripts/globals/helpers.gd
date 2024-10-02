extends Node

func merge_dicts_recursively(a: Dictionary, b: Dictionary) -> Dictionary:
	if len(b.keys()) == 0: return a
	if a.has(b.keys()[0]):
		a[b.keys()[0]] = merge_dicts_recursively(a[b.keys()[0]], b[b.keys()[0]])
	else:
		a.merge(b)
	return a

func dict_key_to_int_recursively(dict: Dictionary) -> Dictionary:
	for key in dict.keys():
		var int_key = int(key)
		dict[int_key] = dict[key].duplicate(true)
		if dict[int_key] is Dictionary: dict_key_to_int_recursively(dict[int_key])
		dict.erase(key)
	return dict

func get_position_on_building_grid(position: Vector2) -> Vector2:
	return round(position / Global.building_grid_size) * Global.building_grid_size
