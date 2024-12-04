extends Block
class_name BuiltinBlock

@export var input_terminal_count: int
@export var output_terminal_count: int

func _ready() -> void:
	setup_step_one()

	if block_height < input_terminal_count * terminal_height:
		label_node.size.y = (input_terminal_count + 1) * Global.building_grid_size
		block_height = (input_terminal_count + 1) * Global.building_grid_size

	if block_height < output_terminal_count * terminal_height:
		label_node.size.y = (output_terminal_count + 1) * Global.building_grid_size
		block_height = (output_terminal_count + 1) * Global.building_grid_size

	setup_step_two()

	if input_terminal_count % 2 == 0:
		input_terminals = instantiate_terminal_even_count(input_terminal_count, -offset.x, false)
	else:
		input_terminals = instantiate_terminal_odd_count(input_terminal_count, -offset.x, false)
	if output_terminal_count % 2 == 0:
		output_terminals = instantiate_terminal_even_count(output_terminal_count, block_width + offset.x, true)
	else:
		output_terminals = instantiate_terminal_odd_count(output_terminal_count, block_width + offset.x, true)

	setup_step_three()

# instantiating the terminals
func instantiate_terminal_even_count(count: int, x_position: float, is_input: bool) -> Array[Terminal]:
	var half_point = int(count / 2.0)
	var half_point_position = block_height / 2
	var terminals: Array[Terminal] = []
	for i in range(count):
		# we either move the terminal down or up depending on if we are above or below the middle
		if i < half_point:
			var terminal_position: Vector2 = Vector2(x_position, half_point_position - (i % half_point + 1) * Global.building_grid_size)
			terminals.append(instantiate_single_terminal(terminal_position, is_input))
		else:
			var terminal_position: Vector2 = Vector2(x_position, half_point_position + (i % half_point + 1) * Global.building_grid_size)
			terminals.append(instantiate_single_terminal(terminal_position, is_input))
	return terminals
func instantiate_terminal_odd_count(count: int, x_position: float, is_input: bool) -> Array[Terminal]:
	var half_point = int((count - 1) / 2.0)
	var half_point_position = block_height / 2
	var terminals: Array[Terminal] = []
	for i in range(count):
		# we either move the terminal down or up or not depending on if we are below or above the middle
		if i < half_point:
			var terminal_position: Vector2 = Vector2(x_position, half_point_position - (Global.building_grid_size * (i % half_point + 1)))
			terminals.append(instantiate_single_terminal(terminal_position, is_input))
		elif i == half_point:
			var terminal_position: Vector2 = Vector2(x_position, half_point_position)
			terminals.append(instantiate_single_terminal(terminal_position, is_input))
		else:
			var terminal_position: Vector2 = Vector2(x_position, half_point_position + (Global.building_grid_size * (i % half_point + 1)))
			terminals.append(instantiate_single_terminal(terminal_position, is_input))
	return terminals
func instantiate_single_terminal(terminal_position: Vector2, is_input: bool) -> Terminal:
	var terminal_instance: Terminal = terminal_scene.instantiate()
	terminal_instance.global_position = terminal_position
	terminal_instance.input_terminal = is_input
	terminal_instance.allow_user_input = false
	terminal_instance.parent_block = self
	terminal_instance.mode = Global.Mode.BLOCK
	terminal_instance.name = str(int(str(get_children()[-1].name)) + 1) if get_children()[-1].name != "label" else '0'
	add_child(terminal_instance)
	return terminal_instance
