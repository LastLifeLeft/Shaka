if (sprite_index == spr_splash)
{
	image_index = image_number - 1;
	image_speed = 0;
	PP.transition_start(-1, PP_TRANSITION.FADE_OUT, {destination: rm_menu});
}