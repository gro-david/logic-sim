extends Block

func update_states():
	outgoing[0].state = Global.State.ON if incoming[0].state == Global.State.ON and incoming[1].state == Global.State.ON else Global.State.OFF
