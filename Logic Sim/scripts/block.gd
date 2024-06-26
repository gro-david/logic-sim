extends Node2D
class_name Block

@export_category('Terminals')
@export var incoming_count: int
@export var outgoing_count: int
@export var incoming: Array[Terminal]
@export var outgoing: Array[Terminal]

@export_category('Config')
@export var color: Color
@export var label: String
@export var offset: Vector2
@export var build_mode: bool

@export_category('Nodes')
@export var label_node: Label

@export_category('Scenes')
@export var terminal_scene: PackedScene

var terminal_height: float
var block_height: float
var block_width: float

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta('type', 'block')

	var terminal_instance: Terminal = terminal_scene.instantiate()
	terminal_height = terminal_instance.sprite.texture.get_height() * terminal_instance.scale.y

	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = color

	# set the text with the addition of two spaces as paddings
	label_node.text = ' ' + label.to_upper() + ' '
	# set a stylebox for background
	label_node.add_theme_stylebox_override('normal', style_box)

	block_height = label_node.get_minimum_size().y
	block_width = label_node.get_minimum_size().x

	if block_height < incoming_count * terminal_height:
		label_node.size.y = incoming_count * terminal_height
		block_height = incoming_count * terminal_height
	
	if block_height < outgoing_count * terminal_height:
		label_node.size.y = outgoing_count * terminal_height
		block_height = outgoing_count * terminal_height

	if incoming_count % 2 == 0:
		incoming = instantiate_terminal_even_count(terminal_scene, incoming_count, -offset.x, block_height / 2, terminal_height, true, false)
	else:
		incoming = instantiate_terminal_odd_count(terminal_scene, incoming_count, -offset.x, block_height / 2, terminal_height, true, false)
	if outgoing_count % 2 == 0:
		outgoing = instantiate_terminal_even_count(terminal_scene, outgoing_count, block_width + offset.x, block_height / 2, terminal_height, false, true)
	else:
		outgoing = instantiate_terminal_odd_count(terminal_scene, outgoing_count, block_width + offset.x, block_height / 2, terminal_height, false, true)
	
	for terminal in incoming:
		terminal.state_changed.connect(update_states.bind())

	Global.edit_wires_changed.connect(update_states.bind())

	update_states()

func update_states():
	printerr(self.to_string() + ' update_states needs to be implemented by the dependant class')

func instantiate_terminal_even_count(terminal: PackedScene, count: int, x_position: float, center_y_position: float, height: float, flip: bool, is_input: bool) -> Array[Terminal]:
	var half_point = int(count / 2.0)
	var terminals: Array[Terminal] = []
	for i in range(count):
		# we either move the terminal down or up depending on if we are above or below the middle
		if i < half_point:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position + ((i % half_point) * height + 0.5 * height))
			terminal_instance.scale.x *= - 1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = false
			terminals.append(terminal_instance)
			terminal_instance.parent_block = self
			add_child(terminal_instance)
		else:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position - ((i % half_point) * height + 0.5 * height))
			terminal_instance.scale.x *= - 1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = false
			terminals.append(terminal_instance)
			terminal_instance.parent_block = self
			add_child(terminal_instance)
	return terminals

func instantiate_terminal_odd_count(terminal: PackedScene, count: int, x_position: float, center_y_position: float, height: float, flip: bool, is_input: bool) -> Array[Terminal]:
	var half_point = int((count - 1) / 2.0)
	var terminals: Array[Terminal] = []
	for i in range(count):
		# we either move the terminal down or up or not depending on if we are below or above the middle
		if i < half_point:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position + ((i % half_point) + 1) * height)
			terminal_instance.scale.x *= - 1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = false
			terminals.append(terminal_instance)
			terminal_instance.parent_block = self
			add_child(terminal_instance)
		elif i == half_point:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position)
			terminal_instance.scale.x *= - 1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = false
			terminal_instance.parent_block = self
			terminals.append(terminal_instance)
			add_child(terminal_instance)
		else:
			var terminal_instance: Terminal = terminal.instantiate()
			terminal_instance.global_position = Vector2(x_position, center_y_position - ((i % half_point) + 1) * height)
			terminal_instance.scale.x *= - 1 if flip else 1
			terminal_instance.input_terminal = is_input
			terminal_instance.allow_user_input = false
			terminals.append(terminal_instance)
			terminal_instance.parent_block = self
			add_child(terminal_instance)
	return terminals

func _process(_delta):
	if not build_mode: return
	global_position = get_global_mouse_position()

	if Input.is_action_just_pressed('mouse_click'):
		build_mode = false
		show()