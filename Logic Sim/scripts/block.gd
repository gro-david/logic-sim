extends Node2D
class_name Block

@export_category('Terminals')
@export var input_terminals: Array[Terminal]
@export var output_terminals: Array[Terminal]

@export_category('Config')
@export var color: Color
@export var label: String
@export var offset: Vector2
@export var build_mode: bool
@export var move_mode: bool
@export var block_name: String
@export var multi_placement_y_gap: float = 0

@export_category('Nodes')
@export var label_node: Label

@export_category('Scenes')
@export var terminal_scene: PackedScene

var terminal_height: float
var block_height: float
var block_width: float

var placement_offset: Vector2 = Vector2.ZERO

func setup_step_one() -> void:
	set_meta('type', 'block')

	var terminal_instance: Terminal = terminal_scene.instantiate()
	terminal_height = terminal_instance.terminal_height * terminal_instance.scale.y

	var style_box: StyleBoxFlat = StyleBoxFlat.new()
	style_box.bg_color = color

	# set the text with the addition of two spaces as paddings
	label_node.text = ' ' + label.to_upper() + ' '
	# set a stylebox for background
	label_node.add_theme_stylebox_override('normal', style_box)

	block_height = max(label_node.get_minimum_size().y + Global.building_grid_size, block_height)
	block_width = max(label_node.get_minimum_size().x + Global.building_grid_size, block_width)

	label_node.size = Vector2(block_width, block_height)
func setup_step_two() -> void:
	$Area2D/CollisionShape2D.shape.size = Vector2(block_width, block_height)
	$Area2D/CollisionShape2D.position += Vector2(block_width, block_height) / 2
func setup_step_three() -> void:
	for terminal in input_terminals:
		terminal.state_changed.connect(update_states.bind())

	Global.edit_wires_changed.connect(update_states.bind())
	update_states()

# moving the blocks when placing and or moving it
func _process(_delta):
	if not build_mode and not move_mode: return
	if Input.is_action_pressed('escape') and not move_mode:
		Global.block_placed.emit()
		queue_free()
	# global_position = Helpers.get_position_on_building_grid(get_global_mouse_position()) + placement_offset
	global_position = Helpers.get_position_on_building_grid(get_global_mouse_position()) + placement_offset - Vector2(block_width, block_height) / 2

	for terminal in input_terminals:
		if not terminal.connected_wire: continue
		terminal.connected_wire.calculate_line_points()
	for terminal in output_terminals:
		if not terminal.connected_wire: continue
		terminal.connected_wire.calculate_line_points()

	if Input.is_action_just_pressed('mouse_click') and not Global.cursor_on_ui and not Global.cursor_in_element:
		build_mode = false
		placement_offset = Vector2.ZERO
		Global.block_placed.emit()
		show()
		# get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed('mouse_r_click'):
		Global.block_placed.emit()
		queue_free()

func update_states():
	printerr(self.to_string() + ' update_states needs to be implemented by the dependant class')

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
