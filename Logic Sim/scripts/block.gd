extends Node2D
class_name Block

@export_category('Terminals')
@export var incoming_count: int
@export var outgoing_count: int
@export var incoming: Array[Terminal]
@export var outgoing: Array[Terminal]

# Called when the node enters the scene tree for the first time.
func _ready():
	for terminal in incoming:
		terminal.state_changed.connect(update_states.bind())

func update_states():
	printerr('Needs to be implemented by the dependant class')