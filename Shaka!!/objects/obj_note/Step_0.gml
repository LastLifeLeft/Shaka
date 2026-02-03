if (!instance_exists(obj_game_controller)) {
    instance_destroy();
    exit;
}

// Move note outward from center
current_distance += approach_speed;

// Check if note is too far past the pad (despawn)
if (current_distance > PAD_RADIUS + 100) {
    instance_destroy();
    exit;
}

// Update hit effect
if (hit_effect) {
    hit_effect_timer++;
    
    if (hit_effect_timer >= hit_effect_duration) {
        instance_destroy();
        exit;
    }
}