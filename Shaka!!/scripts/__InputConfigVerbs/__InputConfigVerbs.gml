function __InputConfigVerbs()
{
    enum INPUT_VERB
    {
        //Add your own verbs here!
        HIGH_LEFT,      // 0 - Top left position
        HIGH_MID,       // 1 - Top middle position
        HIGH_RIGHT,     // 2 - Top right position
        LOW_LEFT,       // 3 - Bottom left position
        LOW_MID,        // 4 - Bottom middle position
        LOW_RIGHT,      // 5 - Bottom right position
        SHAKE,          // 6 - Shake gesture
        UP,
        DOWN,
        LEFT,
        RIGHT,
        ACCEPT,
        CANCEL,
        ACTION,
        SPECIAL,
        PAUSE,
    }
    
    enum INPUT_CLUSTER
    {
        //Add your own clusters here!
        //Clusters are used for two-dimensional checkers (InputDirection() etc.)
        NAVIGATION,
    }
	
    // High row (Q, W, E)
    InputDefineVerb(INPUT_VERB.HIGH_LEFT,  "high_left",  "Q", [gp_shoulderl, gp_padl]);
    InputDefineVerb(INPUT_VERB.HIGH_MID,   "high_mid",   "W", [gp_face3, gp_padu]);
    InputDefineVerb(INPUT_VERB.HIGH_RIGHT, "high_right", "E", [gp_shoulderr, gp_padr]);
    
    // Low row (A, S, D)
    InputDefineVerb(INPUT_VERB.LOW_LEFT,   "low_left",   "A", gp_shoulderlb);
    InputDefineVerb(INPUT_VERB.LOW_MID,    "low_mid",    "S", [gp_face1, gp_padd]);
    InputDefineVerb(INPUT_VERB.LOW_RIGHT,  "low_right",  "D", gp_shoulderrb);
    
    // Shake (spacebar or both triggers)
    InputDefineVerb(INPUT_VERB.SHAKE,      "shake",      vk_space, [gp_face2, gp_face4]);
	
    InputDefineVerb(INPUT_VERB.UP,      "up",         [vk_up,    "W"],    [-gp_axislv, gp_padu]);
    InputDefineVerb(INPUT_VERB.DOWN,    "down",       [vk_down,  "S"],    [ gp_axislv, gp_padd]);
    InputDefineVerb(INPUT_VERB.LEFT,    "left",       [vk_left,  "A"],    [-gp_axislh, gp_padl]);
    InputDefineVerb(INPUT_VERB.RIGHT,   "right",      [vk_right, "D"],    [ gp_axislh, gp_padr]);
    InputDefineVerb(INPUT_VERB.ACCEPT,  "accept",      vk_space,            gp_face1);
    InputDefineVerb(INPUT_VERB.CANCEL,  "cancel",      vk_backspace,        gp_face2);
    InputDefineVerb(INPUT_VERB.ACTION,  "action",      vk_enter,            gp_face3);
    InputDefineVerb(INPUT_VERB.SPECIAL, "special",     vk_shift,            gp_face4);
    InputDefineVerb(INPUT_VERB.PAUSE,   "pause",       vk_escape,           gp_start);
    
    //Define a cluster of verbs for moving around
    InputDefineCluster(INPUT_CLUSTER.NAVIGATION, INPUT_VERB.UP, INPUT_VERB.RIGHT, INPUT_VERB.DOWN, INPUT_VERB.LEFT);
}



