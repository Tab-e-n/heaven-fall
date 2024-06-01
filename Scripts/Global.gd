extends Node


enum {LEVEL_BEATEN, LEVEL_TIME}


const SAVEFILE_NAME : String = "user://plattwo.json"
var DEFAULT_LEVEL_SAVE : Array = [false, -1.0]
var DEFAULT_SAVEFILE : Dictionary = {
	"Tutorial" : DEFAULT_LEVEL_SAVE.duplicate(),
	"Fall Right" : DEFAULT_LEVEL_SAVE.duplicate(),
	"version" : 0,
	"return_position" : {
		"valid" : false,
		"position" : [0, 0],
		"level" : "",
		"timer" : -1,
	},
	"up_key_jump" : true,
}
const DEFAULT_SCENE : String = "res://Levels/main_stage.tscn"


var savefile : Dictionary = {
}

var use_saved_pos : bool = false
var save_player : bool = false
var saved_player_pos : Vector2 = Vector2(0, 0)
var saved_player_timer : float = -1
var current_scene : String = ""

var quit : bool = false


func _ready():
	load_game()


func _physics_process(_delta):
	if quit:
		get_tree().current_scene.queue_free.call_deferred()
		get_tree().quit.call_deferred()
		return
	if Input.is_action_just_pressed("exit"):
		#print("exitting")
		if current_scene == DEFAULT_SCENE:
			save_game()
			quit = true
			return
		else:
			change_scene(DEFAULT_SCENE)
	
	#print(save_player)


func save_game():
	#print("saving: ", save_player)
	if save_player:
		savefile["return_position"]["valid"] = true
		savefile["return_position"]["position"] = [saved_player_pos.x, saved_player_pos.y]
		savefile["return_position"]["timer"] = saved_player_timer
		savefile["return_position"]["level"] = current_scene
	else:
		savefile["return_position"]["valid"] = false
	
	var file = FileAccess.open(SAVEFILE_NAME, FileAccess.WRITE)
	
	var json = JSON.stringify(savefile)
	
	file.store_string(json)
	
	file.close()
	
	#print(get_stack())
	#print("saved: ", savefile)


func load_game():
	if not FileAccess.file_exists(SAVEFILE_NAME):
		savefile = DEFAULT_SAVEFILE.duplicate(true)
		save_game()
		return
	
	var json = FileAccess.get_file_as_string(SAVEFILE_NAME)
	
	var temp = JSON.parse_string(json)
	
	fix_save(temp)
	
	savefile = temp
	
	#print("loaded: ", savefile)


func fix_save(save : Dictionary):
	for i in DEFAULT_SAVEFILE.keys():
		var replace : bool = false
		if not save.has(i):
			replace = true
		elif typeof(save[i]) != typeof(DEFAULT_SAVEFILE[i]):
			replace = true
		
		if replace:
			match typeof(DEFAULT_SAVEFILE[i]):
				[TYPE_ARRAY, TYPE_DICTIONARY]:
					save[i] = DEFAULT_SAVEFILE[i].duplicate(true)
				_:
					save[i] = DEFAULT_SAVEFILE[i]


func save_check(key : String) -> bool:
	if savefile.has(key):
		return savefile[key]
	if DEFAULT_SAVEFILE.has(key):
		return DEFAULT_SAVEFILE[key]
	return false


func clear_saved_pos(starting_position : Vector2):
	save_player = false
	saved_player_pos = starting_position
	saved_player_timer = -1
	save_game()


func return_to_last_level_position():
	use_saved_pos = false
	if not savefile["Tutorial"][LEVEL_BEATEN]:
		#print("Go Beat Tut")
		get_tree().change_scene_to_file("res://Levels/tutorial.tscn")
		return
	
	if savefile.has("return_position"):
		if savefile["return_position"]["valid"]:
			#print("returning")
			use_saved_pos = true
			saved_player_pos.x = savefile["return_position"]["position"][0]
			saved_player_pos.y = savefile["return_position"]["position"][1]
			saved_player_timer = savefile["return_position"]["timer"]
			get_tree().change_scene_to_file(savefile["return_position"]["level"])
		else:
			#print("start anew")
			get_tree().change_scene_to_file(DEFAULT_SCENE)
	else:
		get_tree().change_scene_to_file(DEFAULT_SCENE)


func float_to_time(f : float) -> String:
	var s_sign : String = ""
	if f < 0:
		s_sign = "-"
	f = abs(f)
	@warning_ignore("integer_division")
	var minutes : int = int(f) / 60
	var mod_minutes : float = (f - (minutes * 60))
	var seconds : int = int(mod_minutes)
	var miliseconds : float = mod_minutes - float(seconds)
	
	var s_minutes = String.num(minutes)
	@warning_ignore("integer_division")
	var s_seconds = String.num(int(seconds) / 10) + String.num(int(seconds) % 10)
	var s_miliseconds = String.num(int(miliseconds * 1000))
	
	return s_sign + s_minutes + ":" + s_seconds + "." + s_miliseconds


func format_level_save(level : String):
	if not savefile.has(level):
		savefile[level] = DEFAULT_LEVEL_SAVE.duplicate(true)
		return
	if savefile[level].size() > DEFAULT_LEVEL_SAVE.size():
		savefile[level].resize(DEFAULT_LEVEL_SAVE.size())
	for i in range(DEFAULT_LEVEL_SAVE.size()):
		if typeof(savefile[level][i]) != typeof(DEFAULT_LEVEL_SAVE[i]):
			savefile[level][i] = DEFAULT_LEVEL_SAVE[i]


func beat_level(level : String, timer : float = -1.0) -> bool:
	format_level_save(level)
	
	savefile[level][LEVEL_BEATEN] = true
	
	var new_best : bool = false
	if timer != -1.0:
		new_best = save_speedrun_time(timer, level)
	
	save_game()
	
	return new_best


func save_speedrun_time(timer : float, level : String) -> bool:
	if savefile[level][LEVEL_TIME] > timer or savefile[level][LEVEL_TIME] == -1.0:
		savefile[level][LEVEL_TIME] = timer
		return true
	return false


func change_scene(next_scene : String = current_scene):
	if get_tree().change_scene_to_file(next_scene) > 0:
		print("CANT GO TO SCENE ", next_scene)
		next_scene = DEFAULT_SCENE
		get_tree().change_scene_to_file(DEFAULT_SCENE)
	current_scene = next_scene

