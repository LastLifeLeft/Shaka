transition = function()
{
	PP.signal_unsubscribe(SIGNAL_TRANSITION_ENDED, transition);
	timer = 0;
}

PP.signal_subscribe(SIGNAL_TRANSITION_ENDED, transition);

x = room_width * .5;
y = room_height * .5;

PP.splitview_setup(1, PP_SPLIT.NONE);
PP.splitview_set_view(0, x, y);
PP.transition_start(-1, PP_TRANSITION.FADE_IN, 0, true);

timer = 0;

get_directory_array = function(_path) {
	var _folders = [];
	if (string_char_at(_path, string_length(_path)) != "/") _path += "/";
    
	var _name = file_find_first(_path + "*", fa_directory);
    
	while (_name != "") {
	    if (directory_exists(_path + _name)) {
			array_insert(_folders, 0, _name);
	    }
	    _name = file_find_next();
	}
    
	file_find_close();
	return _folders;
}

get_json_file_array = function(_path) {
    var _files = [];
    if (string_char_at(_path, string_length(_path)) != "/") _path += "/";
    
    var _name = file_find_first(_path + "*.json", 0);
    
    while (_name != "") {
		array_insert(_files, 0, _name);
        _name = file_find_next();
    }
    
    file_find_close();
    return _files;
}

global.music_folder_array = [];

var _path_array = [working_directory + "Music/", game_save_id + "Music/"];
var _current_path, _directory_array, _file_array, _array_lenght, _i, _index, _folder_name, _path_parts ;

while (array_length(_path_array))
{
	_current_path = array_pop(_path_array);
	_directory_array = get_directory_array(_current_path);
	_array_lenght = array_length(_directory_array);
	
	for (_i = 0; _i < _array_lenght; _i ++)
	{
		array_push(_path_array, _current_path + _directory_array[_i] + "/");
	}
	
	_file_array = get_json_file_array(_current_path);
	_array_lenght = array_length(_file_array);
	
	if (_array_lenght)
	{
		_index = array_length(global.music_folder_array);
		_path_parts = string_split(_current_path, "/", true)
		array_push(global.music_folder_array, {folder_name: array_last(_path_parts), path: _current_path, music_list: []});
		
		for (_i = 0; _i < _array_lenght; _i ++)
		{
			// TODO: parse the json to get actual data like the name and the difficulty rating for that song
			var _music_structure = {
									file: _file_array[_i],
									name: "place holder",
									difficulty_rating: [1, 3, 4, 9],
								   };
			
			array_push(global.music_folder_array[_index].music_list, _music_structure);
		}
	}
}