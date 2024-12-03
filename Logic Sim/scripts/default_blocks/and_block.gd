extends Block

func update_states():
	output_terminals[0].state = Global.State.ON if input_terminals[0].state == Global.State.ON and input_terminals[1].state == Global.State.ON else Global.State.OFF
