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
@export var move_mode: bool
@export var block_name: String
@export var multi_placement_y_gap: float = 64

@export_category('Nodes')
@export var label_node: Label

@export_category('Scenes')
@export var terminal_scene: PackedScene

var terminal_height: float
var block_height: float
var block_width: float

var placement_offset: Vector2 = Vector2.ZERO

# instantiating the block and setting
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
	block_width = label_node.get_minimum_size().x + Global.building_grid_size

	label_node.size = Vector2(block_width, block_height)

	if block_height < incoming_count * terminal_height:
		label_node.size.y = (incoming_count + 1) * Global.building_grid_size
		block_height = (incoming_count + 1) * Global.building_grid_size

	if block_height < outgoing_count * terminal_height:
		label_node.size.y = (outgoing_count + 1) * Global.building_grid_size
		block_height = (outgoing_count + 1) * Global.building_grid_size

	$Area2D/CollisionShape2D.shape.size = Vector2(block_width, block_height)
	$Area2D/CollisionShape2D.position += Vector2(block_width, block_height) / 2

	if incoming_count % 2 == 0:
		incoming = instantiate_terminal_even_count(incoming_count, -offset.x, false)
	else:
		incoming = instantiate_terminal_odd_count(incoming_count, -offset.x, false)
	if outgoing_count % 2 == 0:
		outgoing = instantiate_terminal_even_count(outgoing_count, block_width + offset.x, true)
	else:
		outgoing = instantiate_terminal_odd_count(outgoing_count, block_width + offset.x, true)

	for terminal in incoming:
		terminal.state_changed.connect(update_states.bind())

	Global.edit_wires_changed.connect(update_states.bind())

	update_states()

func update_states():
	printerr(self.to_string() + ' update_states needs to be implemented by the dependant class')

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
			var terminal_position: Vector2 = Vector2(x_position, half_point_position - (Global.building_grid_size * (i % half_point)))
			terminals.append(instantiate_single_terminal(terminal_position, is_input))
		elif i == half_point:
			var terminal_position: Vector2 = Vector2(x_position, half_point_position)
			terminals.append(instantiate_single_terminal(terminal_position, is_input))
		else:
			var terminal_position: Vector2 = Vector2(x_position, half_point_position + (Global.building_grid_size * (i % half_point)))
			terminals.append(instantiate_single_terminal(terminal_position, is_input))
	return terminals

func instantiate_single_terminal(terminal_position: Vector2, is_input: bool) -> Terminal:
	var terminal_instance: Terminal = terminal_scene.instantiate()
	terminal_instance.global_position = terminal_position
	terminal_instance.input_terminal = is_input
	terminal_instance.allow_user_input = false
	terminal_instance.parent_block = self
	terminal_instance.name = str(int(str(get_children()[-1].name)) + 1) if get_children()[-1].name != "label" else '0'
	add_child(terminal_instance)
	return terminal_instance

# moving the blocks when placing and or moving it
func _process(_delta):
	if not build_mode and not move_mode: return
	if Input.is_action_pressed('escape') and not move_mode:
		Global.block_placed.emit()
		queue_free()
	# global_position = Helpers.get_position_on_building_grid(get_global_mouse_position()) + placement_offset
	global_position = Helpers.get_position_on_building_grid(get_global_mouse_position()) + placement_offset - Vector2(block_width, block_height) / 2

	for terminal in incoming:
		if not terminal.connected_wire: continue
		terminal.connected_wire.calculate_line_points()
	for terminal in outgoing:
		if not terminal.connected_wire: continue
		terminal.connected_wire.calculate_line_points()

	if Input.is_action_just_pressed('mouse_click') and not Global.cursor_on_ui and not Global.cursor_in_element:
		build_mode = false
		Global.block_placed.emit()
		show()
		# get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed('mouse_r_click'):
		Global.block_placed.emit()
		queue_free()

# used for moving and deleteing the blok
func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if Global.edit_wires: return
	if build_mode: return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			queue_free()
			Global.cursor_in_element = false
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_LEFT and not build_mode:
			move_mode = true
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_released('mouse_click'):
		move_mode = false

# made for detecting if the user is trying to place the block on another block
func _on_area_2d_mouse_entered():
	if build_mode or move_mode: return
	Global.cursor_in_element = true
func _on_area_2d_mouse_exited():
	if build_mode or move_mode: return
	Global.cursor_in_element = false
