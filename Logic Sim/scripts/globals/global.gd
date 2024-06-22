extends Node

enum State {OFF, ON}

func toggle_state(input_state: State) -> State:
	return State.ON if input_state == State.OFF else State.OFF