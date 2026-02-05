// Find rhythm engine if not set
if (!instance_exists(rhythm_engine)) {
    rhythm_engine = instance_find(obj_rhythm_engine, 0);
    
    if (instance_exists(rhythm_engine)) {
        show_debug_message("Input manager connected to rhythm engine");
    }
}