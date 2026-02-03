if (note_data == undefined) {
    instance_destroy();
    exit;
}

// Initialize on first step
if (spawn_time == 0) {
    spawn_time = current_time;
    
    // Calculate approach speed
    // Notes should take NOTE_APPROACH_TIME seconds to reach the pad
    var _distance = target_distance - NOTE_SPAWN_DISTANCE;
    approach_speed = _distance / (NOTE_APPROACH_TIME * game_get_speed(gamespeed_fps));
    
    // Set color based on position
    note_color = get_position_color(note_data.position);
}