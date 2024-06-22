extends Node

signal terminal_changed

# state of the terminals lamps and wires
enum State {OFF, ON}

# when we wre editing the wires we do not want to toggle the terminals, but want to save their instance instead
var edit_wires: bool = false
var terminal: Terminal:
	set(value):
		terminal = value
		terminal_changed.emit()

# can be easily toggled using this fucntion
func toggle_state(input_state: State) -> State:
	return State.ON if input_state == State.OFF else State.OFF
