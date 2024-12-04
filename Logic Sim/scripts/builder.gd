# TODO: I want to identify the blocks the same way the terminals are identified, using a counter that is increasing with every block
# 		and then gets saved in the info part of the block save file. This way the wires will be able to connect correctly even if one of
# 		the blocks gets edited on which this one depends.
extends Node2D
class_name Builder

@export_category('Terminals')
@export var input_terminal_scene: PackedScene
@export var output_terminal_scene: PackedScene

@export_category('Nodes')
@export var blocks: Node2D
@export var wires: Node2D

# different arrays to save all of the terminals. all of them are useful for the different operations but save the same instances of terminals
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

# These will be replaced with id counters. The difference is that these can decrease the id counters cannot. Se above for explanation.
var block_count: int = 0
var wire_count: int = 0

# the name of the block we are building
var built_block_name: String = 'Block Name'
var built_block_color: Color = Color((randf() + 1) / 2, (randf() + 1) / 2, (randf() + 1) / 2)

# these are constants for which dictate where exactly the terminals should be placed, these are either x or y coordinates.
# the offset is only required since the terminals are offset from 0, 0 of their scene and since need to be moved slightly when instantiated as input
const terminal_positions: Dictionary = {Global.Side.TOP: 48, Global.Side.BOTTOM: 1144, Global.Side.LEFT: 16, Global.Side.RIGHT: 1896}
const output_terminal_offset = 10

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
	else:
		output_terminals.append(terminal_instance)

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
	# fetch the expression for the root terminal. since this contains variables (i0, i1, etc.)
	# the terminal inputs for these terminals of the block will need to be fetched, and inserted into the expression instead of the variables.
	# we replace the i with r so that we do not replace stuff twice. (eg. (not (i0 and i1)) then we put two not gates before the inputs essentially creating an or gate. 
	# the result without the r would be (not ((not (not i0)) and (not i0))) instead of (not((not i0) and not(i1))) 
	var terminal_expression_with_vars = root_block.boolean_expressions[str(root_terminal.id)].replace('i','r')
	for root_block_input_terminal in root_block.input_terminals:
		terminal_expression_with_vars = terminal_expression_with_vars.replace("r" + str(root_block_input_terminal.id), get_terminal_input(root_block_input_terminal))
	return terminal_expression_with_vars


# saves the current block that is being built to a json file. it uses the simulaten function that makes it simulate all the states which also get exporteds
func save():
	Helpers.remove_invalid_instances(top_terminals)
	Helpers.remove_invalid_instances(bottom_terminals)
	Helpers.remove_invalid_instances(left_terminals)
	Helpers.remove_invalid_instances(right_terminals)
	Helpers.remove_invalid_instances(input_terminals)
	Helpers.remove_invalid_instances(output_terminals)
	Helpers.remove_invalid_instances(all_terminals)

	top_terminals.sort_custom(Helpers.terminal_sorting_helper_axis_x)
	bottom_terminals.sort_custom(Helpers.terminal_sorting_helper_axis_x)
	left_terminals.sort_custom(Helpers.terminal_sorting_helper_axis_y)
	right_terminals.sort_custom(Helpers.terminal_sorting_helper_axis_y)

	var data: Dictionary = {}

	data['info'] = {
		'block_name': built_block_name,
		'color': built_block_color.to_html(false),
		'terminal_id_counter': terminal_id_counter,
	}
	data['blocks'] = []
	data['wires'] = []
	data['terminals'] = {'top': [], 'bottom': [], 'left': [], 'right': []}

	# we need to invert the bool if the terminal should be an input so that afterwards we can just take that value and use it
	for terminal in top_terminals:
		var terminal_data: Dictionary = {'id': terminal.id, 'color': terminal.on_color, 'x': terminal.global_position.x, 'y': terminal.global_position.y, 'is_input': not terminal.input_terminal, 'label': terminal.label}
		data['terminals']['top'].append(terminal_data)
	for terminal in bottom_terminals:
		var terminal_data: Dictionary = {'id': terminal.id, 'color': terminal.on_color, 'x': terminal.global_position.x, 'y': terminal.global_position.y, 'is_input': not terminal.input_terminal, 'label': terminal.label}
		data['terminals']['bottom'].append(terminal_data)
	for terminal in left_terminals:
		var terminal_data: Dictionary = {'id': terminal.id, 'color': terminal.on_color, 'x': terminal.global_position.x, 'y': terminal.global_position.y, 'is_input': not terminal.input_terminal, 'label': terminal.label}
		data['terminals']['left'].append(terminal_data)
	for terminal in right_terminals:
		var terminal_data: Dictionary = {'id': terminal.id, 'color': terminal.on_color, 'x': terminal.global_position.x, 'y': terminal.global_position.y, 'is_input': not terminal.input_terminal, 'label': terminal.label}
		data['terminals']['right'].append(terminal_data)

	for block in blocks.get_children():
		var block_data: Dictionary = {'index': int(str(block.name)), 'name_id': block.block_name, 'x': block.global_position.x, 'y': block.global_position.y}
		data['blocks'].append(block_data)

	for wire in wires.get_children():
		if not wire.input_terminal or not wire.output_terminal: continue
		var input_terminal_path: String = 'block_' + wire.input_terminal.get_parent().name + '/terminal_' + wire.input_terminal.name
		var output_terminal_path: String = 'block_' + wire.output_terminal.get_parent().name + '/terminal_' + wire.output_terminal.name
		var wire_data: Dictionary = {'input_terminal':  input_terminal_path.replace('block_builder', ''), 'output_terminal': output_terminal_path.replace('block_builder', ''), 'additional_points': wire.additional_points}
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
