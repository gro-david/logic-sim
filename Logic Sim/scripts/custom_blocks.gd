extends Block
class_name CustomBlock

var boolean_expressions: Dictionary
var boolean_expression_variables: Array
var block_data: Dictionary

func _ready() -> void:
	block_name = block_data['info']['block_name']
	label = block_data['info']['block_name'].replace('_', ' ')
	color = Color.from_string(block_data['info']['color'], '#ffffff')
	boolean_expressions = block_data['boolean_expressions']
	boolean_expression_variables = block_data['boolean_expression_variables']
	build_mode = true

	$Area2D/CollisionShape2D.shape = RectangleShape2D.new()

	set_size()
	setup_step_one()

	instantiate_top_terminals()
	instantiate_left_terminals()
	instantiate_right_terminals()
	instantiate_bottom_terminals()

	setup_step_two()
	setup_step_three()

func set_size():
	var max_horizontal_terminal_count = max(len(block_data['terminals']['top']), len(block_data['terminals']['bottom']))
	var max_vertical_terminal_count = max(len(block_data['terminals']['left']), len(block_data['terminals']['right']))

	block_width = max_horizontal_terminal_count * Global.building_grid_size
	block_height = max_vertical_terminal_count * Global.building_grid_size

func instantiate_top_terminals():
	var top_terminals_data: Array = block_data['terminals']['top']

	for i in range(len(top_terminals_data)):
		var terminal = top_terminals_data[i]
		var terminal_instance: Terminal = terminal_scene.instantiate()

		terminal_instance.on_color = Color.from_string(terminal['color'], '#10de10')
		terminal_instance.id = terminal['id']
		terminal_instance.input_terminal = terminal['is_input']
		terminal_instance.label = terminal['label']
		terminal_instance.position = Vector2((i + 0.5) * Global.building_grid_size, 0)
		terminal_instance.rotation = 0.5 * PI
		terminal_instance.side = Global.Side.TOP
		terminal_instance.mode = Global.Mode.BLOCK
		terminal_instance.parent_block = self

		if not terminal_instance.input_terminal:
			input_terminals.append(terminal_instance)
		else:
			output_terminals.append(terminal_instance)

		add_child(terminal_instance)
func instantiate_left_terminals():
	var left_terminals_data: Array = block_data['terminals']['left']

	for i in range(len(left_terminals_data)):
		var terminal = left_terminals_data[i]
		var terminal_instance: Terminal = terminal_scene.instantiate()

		terminal_instance.on_color = Color.from_string(terminal['color'], '#10de10')
		terminal_instance.id = terminal['id']
		terminal_instance.input_terminal = terminal['is_input']
		terminal_instance.label = terminal['label']
		terminal_instance.position = Vector2(0, (i + 0.5) * Global.building_grid_size)
		terminal_instance.side = Global.Side.LEFT
		terminal_instance.mode = Global.Mode.BLOCK
		terminal_instance.parent_block = self

		if not terminal_instance.input_terminal:
			input_terminals.append(terminal_instance)
		else:
			output_terminals.append(terminal_instance)

		add_child(terminal_instance)
func instantiate_right_terminals():
	var right_terminals_data: Array = block_data['terminals']['right']

	for i in range(len(right_terminals_data)):
		var terminal = right_terminals_data[i]
		var terminal_instance: Terminal = terminal_scene.instantiate()

		terminal_instance.on_color = Color.from_string(terminal['color'], '#10de10')
		terminal_instance.id = terminal['id']
		terminal_instance.input_terminal = terminal['is_input']
		terminal_instance.label = terminal['label']
		terminal_instance.position = Vector2(block_width, (i + 0.5) * Global.building_grid_size)
		terminal_instance.side = Global.Side.RIGHT
		terminal_instance.mode = Global.Mode.BLOCK
		terminal_instance.parent_block = self

		if not terminal_instance.input_terminal:
			input_terminals.append(terminal_instance)
		else:
			output_terminals.append(terminal_instance)

		add_child(terminal_instance)
func instantiate_bottom_terminals():
	var bottom_terminals_data: Array = block_data['terminals']['bottom']

	for i in range(len(bottom_terminals_data)):
		var terminal = bottom_terminals_data[i]
		var terminal_instance: Terminal = terminal_scene.instantiate()

		terminal_instance.on_color = Color.from_string(terminal['color'], '#10de10')
		terminal_instance.id = terminal['id']
		terminal_instance.input_terminal = terminal['is_input']
		terminal_instance.label = terminal['label']
		terminal_instance.position = Vector2((i + 0.5) * Global.building_grid_size, block_height)
		terminal_instance.rotation = 0.5 * PI
		terminal_instance.flip()
		terminal_instance.side = Global.Side.BOTTOM
		terminal_instance.mode = Global.Mode.BLOCK
		terminal_instance.parent_block = self

		if not terminal_instance.input_terminal:
			input_terminals.append(terminal_instance)
		else:
			output_terminals.append(terminal_instance)

		add_child(terminal_instance)

func update_states() -> void:
	var incoming_as_bool: Array

	for terminal in input_terminals:
		incoming_as_bool.append(terminal.state == Global.State.ON)

	for terminal in output_terminals:
		var terminal_id = terminal.id
		var expression_statement = boolean_expressions[str(terminal_id)]
		var expression = Expression.new()

		expression.parse(expression_statement, boolean_expression_variables)
		terminal.state = Global.State.ON if expression.execute(incoming_as_bool) else Global.State.OFF
