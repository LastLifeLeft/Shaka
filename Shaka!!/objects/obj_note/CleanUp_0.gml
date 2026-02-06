if (instance_exists(rhythm_engine)) {
	var _index = array_get_index(rhythm_engine.active_notes, id);
	if (_index >= 0) {
		array_delete(rhythm_engine.active_notes, _index, 1);
	}
}