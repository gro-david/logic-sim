extends Block

func update_states():
	outgoing[0].state = Global.State.ON if incoming[0].state == Global.State.OFF else Global.State.OFF
