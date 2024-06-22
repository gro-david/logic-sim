extends Node2D

@export_category('Nodes')
@export var line: Line2D
@export var input_terminal: Terminal
@export var output_terminal: Terminal

@export_category('Colors')
@export var on_color: Color
@export var off_color: Color

var state: Global.State:
	# when this changes, update the color and emit the signal to notify the blocks
	set(value):
		state = value
		line.self_modulate = on_color if state == Global.State.ON else off_color

var start_placed: bool = false:
	set(value):
		start_placed = value
		if start_placed:
			show()
			calculate_line_points()
			
var end_placed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	state = Global.State.OFF
	Global.edit_wires = true
	Global.terminal_changed.connect(set_input_terminal.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	calculate_line_points()

func set_input_terminal():
	input_terminal = Global.terminal
	start_placed = true
	input_terminal.state_changed.connect(update_states.bind())
	Global.terminal_changed.disconnect(set_input_terminal.bind())
	Global.terminal_changed.connect(set_output_terminal.bind())

func set_output_terminal():
	output_terminal = Global.terminal
	end_placed = true
	Global.terminal_changed.disconnect(set_output_terminal.bind())
	Global.edit_wires = false

func calculate_line_points():
	if not start_placed: return
	if end_placed:
		# automatically position the lines, also keep the connections strictly horizontal and vertical
		var center_x = input_terminal.connection_position.x + (output_terminal.connection_position.x - input_terminal.connection_position.x) / 2
		line.points[0] = input_terminal.connection_position
		line.points[1] = Vector2(center_x, input_terminal.connection_position.y)
		line.points[2] = Vector2(center_x, output_terminal.connection_position.y)
		line.points[3] = output_terminal.connection_position
	else:
		# automatically position the lines, also keep the connections strictly horizontal and vertical
		var center_x = input_terminal.connection_position.x + (get_global_mouse_position().x - input_terminal.connection_position.x) / 2
		line.points[0] = input_terminal.connection_position
		line.points[1] = Vector2(center_x, input_terminal.connection_position.y)
		line.points[2] = Vector2(center_x, get_global_mouse_position().y)
		line.points[3] = get_global_mouse_position()

func update_states():
	state = input_terminal.state
	output_terminal.state = input_terminal.state
