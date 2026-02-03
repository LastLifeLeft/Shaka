// Composite all splitview surfaces onto application_surface
splitview_composite();

splitview_draw_borders();

display_draw();

signal_send(SIGNAL_SPLITVIEW_DRAWUI);

with (PP_obj_transition_manager)
{
	draw();
}

if (gameframe_enabled && gameframe_alpha > 0) gameframe_draw();