timer += delta_time;

if (timer >= duration)
{
	if (splitscreen)
	{
		PP.signal_send(SIGNAL_SPLITVIEW_TRANSITION_ENDED);
	}
	else
	{
		PP.signal_send(SIGNAL_TRANSITION_ENDED);
		if (destination != undefined)
		{
			room_goto(destination);
		}
	}
	
	instance_destroy();
}