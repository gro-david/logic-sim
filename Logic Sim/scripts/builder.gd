extends Node2D

@export_category('Terminals')
@export var input_terminal_scene: PackedScene
@export var output_terminal_scene: PackedScene
@export var input_terminal_count: int = 1
@export var output_terminal_count: int = 1
@export var input_terminal_spacing: int = 0
@export var output_terminal_spacing: int = 0
@export var input_terminal_x_position: float = 24
@export var output_terminal_x_position: float = 1896

@export_category('Nodes')
@export var blocks: Node2D
@export var wires: Node2D

@onready var center_y_position: float = get_viewport().size.y / 2
var input_terminal_instance: Terminal
var output_terminal_instance: Terminal
var input_terminal_height: float
var output_terminal_height: float

var input_terminals: Array[Terminal]
var output_terminals: Array[Terminal]

var block_count: int = 0
var wire_count: int = 0

# the name of the block we are building
var built_block_name: String = 'Block Name'
var built_block_color: Color = Color((randf() + 1) / 2, (randf() + 1) / 2, (randf() + 1) / 2)

# Called when the node enters the scene tree for the first time.
func _ready():
	# instantiate the terminals to save the height then delete them
	input_terminal_instance = input_terminal_scene.instantiate()
	input_terminal_height = input_terminal_instance.sprite.texture.get_height() * input_terminal_instance.scale.y + input_terminal_spacing
	input_terminal_instance.queue_free()
	output_terminal_instance = output_terminal_scene.instantiate()
	output_terminal_height = output_terminal_instance.sprite.texture.get_height() * output_terminal_instance.scale.y + output_terminal_spacing

	var input_terminal_count_even := input_terminal_count % 2 == 0
	var output_terminal_count_even := output_terminal_count % 2 == 0

	if input_terminal_count_even: input_terminals = instantiate_terminal_even_count(input_terminal_scene, input_terminal_count, input_terminal_x_position, input_terminal_height, false, true)
	else: input_terminals = instantiate_terminal_odd_count(input_terminal_scene, input_terminal_count, input_terminal_x_position, input_terminal_height, false, true)
	if output_terminal_count_even: output_terminals = instantiate_terminal_even_count(output_terminal_scene, output_terminal_count, output_terminal_x_position, output_terminal_height, true, false)
	else: output_terminals = instantiate_terminal_odd_count(output_terminal_scene, output_terminal_count, output_terminal_x_position, output_terminal_height, true, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func instantiate_terminal_even_count(terminal: PackedScene, count: int, x_position: float, height: float, flip: bool, is_input: bool) -> Array[Terminal]:
	var half_point = int(count / 2.0)
	var terminals: Array[Terminal] = []
	for i in range(count):
		# we either move the terminal down or up depending on if we are above or below the middle
		if i < half_point:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position + ((i % half_point) * height + 0.5 * height))
			terminal_instance.scale.x *= -1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = is_input
			terminal_instance.name = str(int(str(get_children()[-1].name)) + 1) if get_children()[-1].name != "blocks" else '0'
			add_child(terminal_instance)
			terminals.append(terminal_instance)
		else:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position - ((i % half_point) * height + 0.5 * height))
			terminal_instance.scale.x *= -1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = is_input
			terminal_instance.name = str(int(str(get_children()[-1].name)) + 1) if get_children()[-1].name != "blocks" else '0'
			add_child(terminal_instance)
			terminals.append(terminal_instance)
	return terminals

func instantiate_terminal_odd_count(terminal: PackedScene, count: int, x_position: float, height: float, flip: bool, is_input: bool) -> Array[Terminal]:
	var half_point = int((count - 1) / 2.0)
	var terminals: Array[Terminal] = []
	for i in range(count):
		# we either move the terminal down or up or not depending on if we are below or above the middle
		if i < half_point:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position + ((i % half_point) + 1) * height)
			terminal_instance.scale.x *= -1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = is_input
			terminal_instance.name = str(int(str(get_children()[-1].name)) + 1) if get_children()[-1].name != "blocks" else '0'
			add_child(terminal_instance)
			terminals.append(terminal_instance)
		elif i == half_point:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position)
			terminal_instance.scale.x *= -1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = is_input
			terminal_instance.name = str(int(str(get_children()[-1].name)) + 1) if get_children()[-1].name != "blocks" else '0'
			add_child(terminal_instance)
			terminals.append(terminal_instance)
		else:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position - ((i % half_point) + 1) * height)
			terminal_instance.scale.x *= -1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = is_input
			terminal_instance.name = str(int(str(get_children()[-1].name)) + 1) if get_children()[-1].name != "blocks" else '0'
			add_child(terminal_instance)
			terminals.append(terminal_instance)
	return terminals

func simulate() -> Dictionary:
	var result: Dictionary = {}

	for i in range(pow(2, input_terminal_count)):
		var states = String.num_int64(i, 2).pad_zeros(input_terminal_count).split('')
		for j in range(len(input_terminals)):
			var terminal = input_terminals[j]
			terminal.state = int(states[j])
		result = Helpers.merge_dicts_recursively(result, get_input_output())

	for terminal in input_terminals:
		terminal.state = Global.State.OFF

	return result


func get_input_output() -> Dictionary:
	var dict: Dictionary = {}
	var last_dict: Dictionary = dict
	var output_array: Array = []

	for terminal in output_terminals:
		output_array.append(terminal.state)

	for terminal in input_terminals:
		if terminal == input_terminals[-1]:
			last_dict[terminal.state] = output_array
			break
		last_dict[terminal.state] = {}
		last_dict = last_dict[terminal.state]

	return dict

func save():
	var data: Dictionary = {}

	data['info'] = {
		'block_name': built_block_name,
		'input_terminal_count': input_terminal_count,
		'output_terminal_count': output_terminal_count,
		'color': built_block_color.to_html(false)
	}
	data['blocks'] = []
	data['wires'] = []

	for block in blocks.get_children():
		var block_data: Dictionary = {'index': int(str(block.name)), 'name_id': block.block_name, 'x': block.global_position.x, 'y': block.global_position.y}
		data['blocks'].append(block_data)

	for wire in wires.get_children():
		var input_terminal_path: String = 'block_' + wire.input_terminal.get_parent().name + '/terminal_' + wire.input_terminal.name
		var output_terminal_path: String = 'block_' + wire.output_terminal.get_parent().name + '/terminal_' + wire.output_terminal.name
		var wire_data: Dictionary = {'input_terminal':  input_terminal_path.replace('block_builder', ''), 'output_terminal': output_terminal_path.replace('block_builder', '')}
		data['wires'].append(wire_data)

	data['permutations'] = simulate()

	if not DirAccess.dir_exists_absolute(Global.block_path): DirAccess.make_dir_absolute(Global.block_path)

	var json: String = JSON.stringify(data)
	var save_file = FileAccess.open('user://blocks/' + data['info']['block_name'] + '.json', FileAccess.WRITE)

	save_file.store_string(json)
