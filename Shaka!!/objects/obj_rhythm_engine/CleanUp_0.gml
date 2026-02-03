for (var i = 0; i < array_length(active_notes); i++) {
    if (instance_exists(active_notes[i])) {
        instance_destroy(active_notes[i]);
    }
}
