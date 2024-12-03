extends Node2D
class_name Builder

@export_category('Terminals')
@export var input_terminal_scene: PackedScene
@export var output_terminal_scene: PackedScene
@export var input_terminal_count: int = 0
@export var output_terminal_count: int = 0
@export var input_terminal_spacing: int = 0
@export var output_terminal_spacing: int = 0

@export_category('Nodes')
@export var blocks: Node2D
@export var wires: Node2D

# different arrays to save all of the terminals. all of them are useful for the different operations
var top_terminals: Array[Terminal]
var bottom_terminals: Array[Terminal]
var left_terminals: Array[Terminal]
var right_terminals: Array[Terminal]
var input_terminals: Array[Terminal]
var output_terminals: Array[Terminal]
var all_terminals: Array[Terminal]

# this counter is used for the id which means that it will never be decremented and the id of the terminal will just be the value of this counter
# the only possible problem with this approach is if the user goes up to INTMAX with the number of terminals
var terminal_id_counter: int

var block_count: int = 0
var wire_count: int = 0

# the name of the block we are building
var built_block_name: String = 'Block Name'
var built_block_color: Color = Color((randf() + 1) / 2, (randf() + 1) / 2, (randf() + 1) / 2)

var terminal_positions: Dictionary = {Global.Side.TOP: 48, Global.Side.BOTTOM: 1144, Global.Side.LEFT: 16, Global.Side.RIGHT: 1896}
var output_terminal_offset = 10

# this instantiates a terminal with the correct variables set and saves it in the correct array
func instantiate_terminal(terminal: PackedScene, click_position: Vector2, is_input: bool, side: Global.Side):
	var terminal_instance: Terminal = terminal.instantiate()

	terminal_instance.global_position = Helpers.get_position_on_building_grid(click_position)
	terminal_instance.side = side
	terminal_instance.mode = Global.Mode.BUILDER
	terminal_instance.id = terminal_id_counter
	terminal_instance.input_terminal = is_input
	terminal_instance.allow_user_input = is_input
	terminal_instance.name = str(terminal_instance.id)

	terminal_id_counter += 1

	match side:
		Global.Side.LEFT:
			terminal_instance.global_position.x = terminal_positions[Global.Side.LEFT]
			if not is_input: terminal_instance.flip()
			left_terminals.append(terminal_instance)
		Global.Side.RIGHT:
			terminal_instance.global_position.x = terminal_positions[Global.Side.RIGHT]
			if is_input: terminal_instance.flip()
			right_terminals.append(terminal_instance)
		Global.Side.TOP:
			terminal_instance.rotation = 0.5 * PI
			terminal_instance.global_position.y = terminal_positions[Global.Side.TOP]
			if not is_input: terminal_instance.flip()
			top_terminals.append(terminal_instance)
		Global.Side.BOTTOM:
			terminal_instance.rotation = 0.5 * PI
			terminal_instance.global_position.y = terminal_positions[Global.Side.BOTTOM]
			if is_input: terminal_instance.flip()
			bottom_terminals.append(terminal_instance)

	if is_input:
		input_terminals.append(terminal_instance)
		input_terminal_count = len(input_terminals)
	else:
		output_terminals.append(terminal_instance)
		output_terminal_count = len(output_terminals)

	all_terminals.append(terminal_instance)

	add_child(terminal_instance)

# cycles through all of the possible states of the inputs, then gets their outputs and merges the output dicts
func simulate() -> Dictionary:
	var expression_variables: Array[String]
	var expressions: Dictionary

	for terminal in input_terminals:
		expression_variables.append('i' + str(terminal.id))

	for terminal in output_terminals:
		expressions[terminal.id] = get_terminal_input(terminal)

	return {'expressions': expressions, 'variables': expression_variables}

func get_terminal_input(terminal: Terminal) -> String:
	var wire: Wire = terminal.connected_wire
	if wire == null: return '(null)'

	var root_terminal: Terminal = wire.input_terminal
	if root_terminal == null: return '(null)'

	var root_block: Block = root_terminal.parent_block
	if root_block == null:
		return 'i' + str(wire.input_terminal.id)

	if root_block is not CustomBlock:
		match root_block.block_name:
			'builtin_and': return '(' + get_terminal_input(root_block.input_terminals[0]) + ' and ' + get_terminal_input(root_block.input_terminals[1]) + ')'
			'builtin_not': return '(not ' + get_terminal_input(root_block.input_terminals[0]) + ')'

	root_block = root_block as CustomBlock
	var root_block_input_expressions: Array[String] = []
	for root_block_input_terminal in root_block.input_terminals:
		root_block_input_expressions.append(get_terminal_input(root_block_input_terminal))

	return root_block.get_boolean_expression(root_block_input_expressions)

# saves the current block that is being built to a json file. it uses the simulaten function that makes it simulate all the states which also get exporteds
func save():
	top_terminals.sort_custom(Helpers.terminal_sorting_helper_axis_x)
	bottom_terminals.sort_custom(Helpers.terminal_sorting_helper_axis_x)
	left_terminals.sort_custom(Helpers.terminal_sorting_helper_axis_y)
	right_terminals.sort_custom(Helpers.terminal_sorting_helper_axis_y)

	var data: Dictionary = {}

	data['info'] = {
		'block_name': built_block_name,
		'input_terminal_count': input_terminal_count,
		'output_terminal_count': output_terminal_count,
		'color': built_block_color.to_html(false),
		'terminal_id_counter': terminal_id_counter,
	}
	data['input_terminals'] = []
	data['output_terminals'] = []
	data['blocks'] = []
	data['wires'] = []

	for i in range(len(input_terminals)):
		var terminal = input_terminals[i]
		if not is_instance_valid(terminal): continue
		var terminal_data = {'id': terminal.id, 'color': terminal.on_color, 'x': terminal.global_position.x, 'y': terminal.global_position.y}
		data['input_terminals'].append(terminal_data)

	for i in range(len(output_terminals)):
		var terminal = output_terminals[i]
		if not is_instance_valid(terminal): continue
		var terminal_data = {'id': terminal.id, 'color': terminal.on_color, 'x': terminal.global_position.x, 'y': terminal.global_position.y}
		data['output_terminals'].append(terminal_data)

	for block in blocks.get_children():
		var block_data: Dictionary = {'index': int(str(block.name)), 'name_id': block.block_name, 'x': block.global_position.x, 'y': block.global_position.y}
		data['blocks'].append(block_data)

	for wire in wires.get_children():
		if not wire.input_terminal or not wire.output_terminal: continue
		var input_terminal_path: String = 'block_' + wire.input_terminal.get_parent().name + '/terminal_' + wire.input_terminal.name
		var output_terminal_path: String = 'block_' + wire.output_terminal.get_parent().name + '/terminal_' + wire.output_terminal.name
		var wire_data: Dictionary = {'input_terminal':  input_terminal_path.replace('block_builder', ''), 'output_terminal': output_terminal_path.replace('block_builder', '')}
		data['wires'].append(wire_data)

	var simulation_result: Dictionary = simulate()
	data['boolean_expressions'] = simulation_result['expressions']
	data['boolean_expression_variables'] = simulation_result['variables']

	if not DirAccess.dir_exists_absolute(Global.block_path): DirAccess.make_dir_absolute(Global.block_path)

	var json: String = JSON.stringify(data)
	var save_file = FileAccess.open('user://blocks/' + data['info']['block_name'] + '.json', FileAccess.WRITE)

	save_file.store_string(json)
	$ui._on_clear_confirmed()
	$ui.load_custom_blocks.call_deferred()
