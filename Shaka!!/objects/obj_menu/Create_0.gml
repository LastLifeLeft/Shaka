// Initialize PP Framework if not already done
if (!variable_global_exists("__pp_initialized")) {
    PP.display_set_target_size(640, 360);
    PP.display_set_mode(PP_DISPLAY_MODE.PIXEL);
    PP.display_set_ratio(16/9, 16/9);
}

PP.display_set_target_size(640, 360);
x = room_width * .5;
y = room_height * .5;
PP.splitview_setup(1);
PP.splitview_set_view(0, x, y);
PP.display_set_ratio(16/9, 16/9);

// Create menu using PP_Menu
menu = new PP_Menu(0);

menu.AddItem("Start Game", function() { PP.transition_start(-1, PP_TRANSITION.FADE_OUT, { duration: 300000, destination: rm_game });})
    .AddItem("Quit", function() { game_end(); })
    .SetHAlignment(fa_center)
    .SetVAlignment(fa_middle)
    .SetCancelAction(1);

show_debug_message("Menu created");