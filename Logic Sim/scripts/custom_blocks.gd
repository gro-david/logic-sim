extends Block
class_name CustomBlock

var permutations: Dictionary
var block_data: Dictionary

func _ready() -> void:
	block_name = block_data['info']['block_name']
	incoming_count = block_data['info']['input_terminal_count']
	outgoing_count = block_data['info']['output_terminal_count']
	label = block_data['info']['block_name'].replace('_', ' ')
	color = Color.from_string(block_data['info']['color'], '#ffffff')
	permutations = Helpers.dict_key_to_int_recursively(block_data['permutations'])
	build_mode = true

	$Area2D/CollisionShape2D.shape = RectangleShape2D.new()

	super()

func update_states():
	var last_dict: Dictionary = permutations
	var outgoing_states: Array
	for terminal in incoming:
		if terminal == incoming[-1]:
			outgoing_states = last_dict[terminal.state]
			break
		last_dict = last_dict[terminal.state]
	for i in range(len(outgoing)):
		var terminal: Terminal = outgoing[i]
		terminal.state = outgoing_states[i]
