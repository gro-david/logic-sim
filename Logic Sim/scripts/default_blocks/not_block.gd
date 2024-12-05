extends BuiltinBlock

func update_states():
	output_terminals[0].state = Global.State.ON if input_terminals[0].state == Global.State.OFF else Global.State.OFF
