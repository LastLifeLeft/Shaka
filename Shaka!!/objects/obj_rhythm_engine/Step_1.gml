// Initialize highway context if not set
if (highway_context == undefined) {
    var _highway = instance_find(obj_note_highway, 0);
    if (instance_exists(_highway)) {
        highway_context = new HighwayContext(_highway.x, _highway.y, _highway.highway_radius, _highway.mode);
        show_debug_message($"Highway context initialized from obj_note_highway at ({_highway.x}, {_highway.y})");
    }
}