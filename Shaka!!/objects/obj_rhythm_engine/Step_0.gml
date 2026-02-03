if (!is_playing) exit;

var _controller = obj_game_controller;
var _chart = global.current_chart;

// Spawn new notes
var _next_note = _chart.get_next_note(_controller.current_time_ms);
while (_next_note != undefined) {
    spawn_note(_next_note);
    _next_note = _chart.get_next_note(_controller.current_time_ms);
}

// Update active notes
for (var i = array_length(active_notes) - 1; i >= 0; i--) {
    var _note_obj = active_notes[i];
    
    // Check if note passed the pad and wasn't hit
    // In circular layout, check if distance exceeded pad radius
    var _distance_past = _note_obj.current_distance - PAD_RADIUS;
    var _max_miss_distance = (TIMING_OK / 1000) * (PAD_RADIUS / NOTE_APPROACH_TIME);
    
    if (_distance_past > _max_miss_distance && !_note_obj.note_data.hit) {
        // Missed the note
        register_hit(_note_obj, NOTE_RATING.MISS);
        instance_destroy(_note_obj);
        array_delete(active_notes, i, 1);
    }
}