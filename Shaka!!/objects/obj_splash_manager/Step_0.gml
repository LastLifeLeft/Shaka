timer += delta_time;

if (timer >= 800000)
{
	timer = 0;
	PP.transition_start(-1, PP_TRANSITION.FADE_OUT, {destination: rm_mainmenu});
}