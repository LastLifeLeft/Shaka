// Note data from chart (set by rhythm engine)
note_data = undefined;
rhythm_engine = noone;

// Circular position
target_distance = PAD_RADIUS;  // Distance from center to pad
current_distance = NOTE_SPAWN_DISTANCE;  // Start at center

// Movement
approach_speed = 0;  // units per frame
spawn_time = 0;

// Visual state
note_color = c_white;
note_alpha = 1.0;

// Hit feedback
hit_effect = false;
hit_rating = NOTE_RATING.MISS;
hit_effect_timer = 0;
hit_effect_duration = 15;  // frames
