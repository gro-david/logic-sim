extends Node

@warning_ignore("unused_signal")
signal block_placed
signal terminal_changed
signal edit_wires_changed

var building_grid_size: int = 28
var block_path: String = 'user://blocks'
var builder_ui: BuilderUI
var cursor_on_ui: bool
var cursor_in_element: bool

# state of the terminals lamps and wires
enum State {OFF, ON}

# the side on which the terminal is
enum Side {LEFT, RIGHT, TOP, BOTTOM}

# which mode is this terminal in, either in the builder or on a placed blocks
enum Mode {BUILDER, BLOCK}

# when we wre editing the wires we do not want to toggle the terminals, but want to save their instance instead
var edit_wires: bool = false:
	set(value):
		edit_wires = value
		edit_wires_changed.emit()
var edit_mode: bool = false
var terminal: Terminal:
	set(value):
		terminal = value
		terminal_changed.emit()

# can be easily toggled using this fucntion
func toggle_state(input_state: State) -> State:
	return State.ON if input_state == State.OFF else State.OFF
