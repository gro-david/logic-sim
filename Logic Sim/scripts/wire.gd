extends Node2D

@export_category('Nodes')
@export var line: Line2D
@export var input_terminal: Terminal
@export var output_terminal: Terminal

@export_category('Colors')
@export var on_color: Color
@export var off_color: Color

@export_group('Test')
@export var state: Global.State:
	# when this changes, update the color and emit the signal to notify the blocks
	set(value):
		state = value
		line.self_modulate = on_color if state == Global.State.ON else off_color

@export var start_placed: bool = false:
	set(value):
		start_placed = value
		if start_placed:
			show()
			calculate_line_points()

@export var end_placed: bool = false:
	set(value):
		end_placed = value
		if end_placed:
			show()
			calculate_line_points()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta('type', 'wire')
	state = Global.State.OFF
	Global.edit_wires = true
	Global.terminal_changed.connect(set_terminal.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	calculate_line_points()
	if start_placed or end_placed:
		global_position = Vector2.ZERO
		calculate_line_points()
	else:
		global_position = get_global_mouse_position()

func set_terminal():
	# if the terminal is the same one as one of the other ones we just return.
	if Global.terminal == input_terminal or Global.terminal == output_terminal: return
	# depending on if the terminal allows input we either set the input or the output
	if Global.terminal.input_terminal:
		set_input_terminal()
	else:
		set_output_terminal()

func set_input_terminal():
	# the input terminal needs to be able to receive input.
	if not Global.terminal.input_terminal: return
	# we do not want allow a recursive connection
	if output_terminal and output_terminal.parent_block and Global.terminal.parent_block == output_terminal.parent_block: return
	# transfer the input terminal and change the signals to correspond to the end of the wire
	input_terminal = Global.terminal
	start_placed = true
	input_terminal.state_changed.connect(update_states.bind())
	# we check if the other terminal is not null. if this is the case the wire has been finished so we disconnect the signal and exit edit mode
	if output_terminal != null:
		Global.terminal_changed.disconnect(set_terminal.bind())
		Global.edit_wires = false

func set_output_terminal():
	# if the output terminal can receive input, its not allowed
	if Global.terminal.input_terminal: return
	# the two terminals cannot be the same one
	if Global.terminal == input_terminal: return
	# we do not want to allow a recursive connection
	if input_terminal and input_terminal.parent_block and Global.terminal.parent_block == input_terminal.parent_block: return
	# save the output terminal and disconnect the signal
	output_terminal = Global.terminal
	end_placed = true
	# we check if the other terminal is not null. if this is the case the wire has been finished so we disconnect the signal and exit edit mode
	if input_terminal != null:
		Global.terminal_changed.disconnect(set_terminal.bind())
		Global.edit_wires = false

func calculate_line_points():
	if end_placed and start_placed:
		# if the wire would come down directly straight we want to offset it
		var center_offset := (output_terminal.connection_node.global_position.x - input_terminal.connection_node.global_position.x) / 2
		if abs(center_offset) < 64:
			center_offset = 64 if input_terminal.connection_node.global_position.x + 64 < get_viewport().size.x else - 64
		# automatically position the lines, also keep the connections strictly horizontal and vertical
		var center_x = input_terminal.connection_node.global_position.x + center_offset
		line.points[0] = input_terminal.connection_node.global_position
		line.points[1] = Vector2(center_x, input_terminal.connection_node.global_position.y)
		line.points[2] = Vector2(center_x, output_terminal.connection_node.global_position.y)
		line.points[3] = output_terminal.connection_node.global_position
	elif start_placed:
		# if the wire would come down directly straight we want to offset it
		var center_offset := (get_global_mouse_position().x - input_terminal.connection_node.global_position.x) / 2
		if abs(center_offset) < 64:
			center_offset = 64 if input_terminal.connection_node.global_position.x + 64 < get_viewport().size.x else - 64
		# automatically position the lines, also keep the connections strictly horizontal and vertical
		var center_x := input_terminal.connection_node.global_position.x + center_offset
		line.points[0] = input_terminal.connection_node.global_position
		line.points[1] = Vector2(center_x, input_terminal.connection_node.global_position.y)
		line.points[2] = Vector2(center_x, get_global_mouse_position().y)
		line.points[3] = get_global_mouse_position()
	elif end_placed:
		# if the wire would come down directly straight we want to offset it
		var center_offset := (get_global_mouse_position().x - output_terminal.connection_node.global_position.x) / 2
		if abs(center_offset) < 64:
			center_offset = 64 if output_terminal.connection_node.global_position.x + 64 < get_viewport().size.x else - 64
		# automatically position the lines, also keep the connections strictly horizontal and vertical
		var center_x := output_terminal.connection_node.global_position.x + center_offset
		line.points[0] = output_terminal.connection_node.global_position
		line.points[1] = Vector2(center_x, output_terminal.connection_node.global_position.y)
		line.points[2] = Vector2(center_x, get_global_mouse_position().y)
		line.points[3] = get_global_mouse_position()


func update_states():
	state = input_terminal.state
	output_terminal.state = input_terminal.state
