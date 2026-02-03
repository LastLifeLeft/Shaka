// Show input visualizer for testing (F2 to toggle)
if (keyboard_check(vk_f2)) {
    draw_set_font(fnt_default);
    draw_set_halign(fa_left);
    draw_set_color(c_white);
    
    var _y = 200;
    draw_text(10, _y, "Input Status (Hold F2):");
    _y += 20;
    
    // Show each position
    var _positions = ["HIGH_LEFT", "HIGH_MID", "HIGH_RIGHT", "LOW_LEFT", "LOW_MID", "LOW_RIGHT"];
    for (var i = 0; i < 6; i++) {
        var _active = InputCheck(i);
        var _color = _active ? c_lime : c_gray;
        var _text = _positions[i] + ": " + (_active ? "PRESSED" : "---");
        
        draw_set_color(_color);
        draw_text(10, _y, _text);
        _y += 15;
    }
    
    // Show shake
    var _shake_active = InputCheck(INPUT_VERB.SHAKE);
    var _shake_color = _shake_active ? c_yellow : c_gray;
    draw_set_color(_shake_color);
    draw_text(10, _y, "SHAKE: " + (_shake_active ? "PRESSED" : "---"));
    
    // Show calibration
    _y += 25;
    draw_set_color(c_white);
    draw_text(10, _y, $"Calibration: {calibration_offset}ms");
}