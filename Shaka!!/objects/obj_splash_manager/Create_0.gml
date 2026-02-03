randomize();

show_debug_overlay(true);

transition = function()
{
	audio_play_sound(snd_splash, 10, false);
	sprite_index = spr_splash;
	image_index = 0;
	PP.signal_unsubscribe(SIGNAL_TRANSITION_ENDED, transition);
}

PP.signal_subscribe(SIGNAL_TRANSITION_ENDED, transition);

x = room_width * .5;
y = room_height * .5;

PP.splitview_setup(1, PP_SPLIT.NONE);
PP.splitview_set_view(0, x, y);
PP.transition_start(-1, PP_TRANSITION.FADE_IN, 0, true);

loading = false;