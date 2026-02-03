// Draw score display
draw_set_font(fnt_default);
draw_set_color(c_white);

// Score at top right
scribble($"[fa_right]SCORE: [c_yellow]{total_score}")
    .draw(630, 10);

// Combo
if (current_combo > 0) {
    var _combo_color = "c_white";
    if (current_combo >= COMBO_TIER4) _combo_color = "c_fuchsia";
    else if (current_combo >= COMBO_TIER3) _combo_color = "c_red";
    else if (current_combo >= COMBO_TIER2) _combo_color = "c_orange";
    
    var _multiplier = get_combo_multiplier(current_combo);
    
    scribble($"[fa_center][{_combo_color}][pulse]COMBO: {current_combo}\n{_multiplier}x")
        .draw(320, 50);
}

// Show last rating
if (current_time - last_rating_time < rating_display_duration) {
    var _rating_color = "c_white";
    var _rating_text = get_rating_name(last_rating);
    
    switch (last_rating) {
        case NOTE_RATING.PERFECT:
            _rating_color = "c_lime";
            _rating_text = "[pulse]" + _rating_text;
            break;
        case NOTE_RATING.GOOD:
            _rating_color = "c_yellow";
            break;
        case NOTE_RATING.OK:
            _rating_color = "c_orange";
            break;
        case NOTE_RATING.MISS:
            _rating_color = "c_red";
            _rating_text = "[shake]" + _rating_text;
            break;
    }
    
    scribble($"[fa_center][{_rating_color}]{_rating_text}")
        .scale(2, 2)
        .draw(CIRCLE_CENTER_X, CIRCLE_CENTER_Y);
}

// Draw statistics at bottom
scribble($"[fa_left][c_lime]Perfect: {perfect_count}  " +
         $"[c_yellow]Good: {good_count}  " +
         $"[c_orange]OK: {ok_count}  " +
         $"[c_red]Miss: {miss_count}")
    .draw(10, 340);