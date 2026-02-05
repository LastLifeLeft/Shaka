/// @description Game constants and enums for Shaka rhythm game

// Note positions (matches INPUT_VERB enum)
enum NOTE_POSITION_SHAKATTO {
    HIGH_LEFT = 0,
    HIGH_MID = 1,
    HIGH_RIGHT = 2,
    LOW_LEFT = 3,
    LOW_MID = 4,
    LOW_RIGHT = 5,
}


enum NOTE_POSITION_SAMBA {
    HIGH_LEFT = 0,
    MID_LEFT = 1,
    LOW_LEFT = 2,
    HIGH_RIGHT = 3,
    MID_RIGHT = 4,
    LOW_RIGHT = 5,
}


// Note types
enum NOTE_TYPE {
    NORMAL,     // Single note
    DOUBLE,     // Two positions at same time
    SHAKE,      // Shake gesture
}

// Game modes
enum GAME_MODE {
    SAMBA,      // Vertical symmetry (original Samba de Amigo)
    SHAKATTO,   // Horizontal symmetry (Shakatto Tambourine)
}

// Hit ratings
enum NOTE_RATING {
    MISS,       // Completely missed
    OK,         // Within OK window
    GOOD,       // Within good window
    PERFECT,    // Within perfect window
}

// Timing windows (in milliseconds, symmetric around note)
#macro TIMING_PERFECT 80    // ±80ms
#macro TIMING_GOOD 120      // ±120ms
#macro TIMING_OK 180        // ±180ms

// Scoring constants
#macro SCORE_PERFECT 100
#macro SCORE_GOOD 80
#macro SCORE_OK 50
#macro SCORE_MISS 0
#macro SCORE_DOUBLE_MULTIPLIER 2.5

// Combo multiplier thresholds
#macro COMBO_TIER1 0   // 1x multiplier
#macro COMBO_TIER2 10  // 2x multiplier
#macro COMBO_TIER3 25  // 3x multiplier
#macro COMBO_TIER4 50  // 4x multiplier

// End-of-song bonuses
#macro BONUS_FULL_COMBO 10000
#macro BONUS_NO_MISS 5000
#macro BONUS_ACCURACY_MAX 5000

// Visual constants
#macro NOTE_HIGHWAY_WIDTH 640
#macro NOTE_HIGHWAY_HEIGHT 360
#macro NOTE_SIZE 32

// Circular layout (Samba de Amigo style)
#macro CIRCLE_CENTER_X 320       // Center of screen
#macro CIRCLE_CENTER_Y 180       // Center of screen
#macro PAD_RADIUS 150            // Distance from center to pads
#macro NOTE_SPAWN_DISTANCE 0     // Notes spawn at center
#macro NOTE_APPROACH_TIME 2.0    // Notes take 2 seconds to reach pads

// Colors for positions
#macro COLOR_HIGH_LEFT c_red
#macro COLOR_HIGH_MID c_yellow
#macro COLOR_HIGH_RIGHT c_lime
#macro COLOR_LOW_LEFT c_blue
#macro COLOR_LOW_MID c_purple
#macro COLOR_LOW_RIGHT c_aqua
#macro COLOR_SHAKE c_white
#macro COLOR_DOUBLE c_orange

