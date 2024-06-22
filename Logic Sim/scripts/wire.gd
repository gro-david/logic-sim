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

# Called when the node enters the scene tree for the first time.
func _ready():
	calculate_line_points()
	update_states()
	input_terminal.state_changed.connect(update_states.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func calculate_line_points():
	var center_x = input_terminal.connection_position.x + (output_terminal.connection_position.x - input_terminal.connection_position.x) / 2
	line.points[0] = input_terminal.connection_position
	line.points[1] = Vector2(center_x, input_terminal.connection_position.y)
	line.points[2] = Vector2(center_x, output_terminal.connection_position.y)
	line.points[3] = output_terminal.connection_position

func update_states():
	state = input_terminal.state
	output_terminal.state = input_terminal.state