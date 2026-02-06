PP.splitview_setup(1);
PP.splitview_set_view(0, room_width * .5, room_height * .5);
PP.display_set_ratio(16/9, 16/9);

menu = new PP_Menu(0);

menu.AddItem("Start Game", function() { 
		PP.transition_start(-1, PP_TRANSITION.FADE_OUT, { duration: 300000, destination: rm_game });
		PP.gameframe_set_forced(false); })
	.AddItem("Options", function() {  })
	.AddItem("Quit", function() { game_end(); })
	.SetHAlignment(fa_center)
	.SetVAlignment(fa_middle)
	.SetCancelAction(1);

