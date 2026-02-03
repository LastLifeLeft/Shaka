randomize();

func_ratio_change = function()
{
	
}

PP.signal_subscribe(SIGNAL_DISPLAY_CHANGE, func_ratio_change);

PP.splitview_setup(3, PP_SPLIT.ROWS_2_1);
PP.splitview_set_border(true, c_fuchsia, 1);

//PP.splitview_set_view(0, 250, 250);
//PP.splitview_set_view(1, 250, 250);
//PP.splitview_set_view(2, 250, 250);
//PP.splitview_set_view(3, 250, 250);
	
PP.transition_start(2, PP_TRANSITION.DIAMONDS_IN);
//PP.transition_start(-1, PP_TRANSITION.DIAMONDS_IN);