extends Node
class_name CutsceneControl


@export var autostart : bool = false

var active : bool = false
var key_amount : int = 0
var current_key : int = 0
var awaiting_input : bool = false
var wait_timer : float = 0.0

@onready var camera : GameCamera = GameCamera.camera


func _ready():
	key_amount = get_child_count()
	
	if autostart:
		start_cutscene()


func _physics_process(delta):
	if awaiting_input:
		if Input.is_action_just_pressed("reset"):
			next_key()
	if not awaiting_input:
		wait_timer -= delta
		while(wait_timer <= 0 and not awaiting_input and active):
			next_key()


func start_cutscene():
	current_key = -1
	active = true
	camera.cutscene = true
	camera.player.clear_input()
	next_key()


func end_cutscene():
	active = false
	camera.cutscene = false
	camera.cutscene_camera = 0
	camera.text_box.new_line("")


func next_key():
	current_key += 1
	if current_key == key_amount:
		end_cutscene()
	else:
		var key : CutsceneKey = get_child(current_key) as CutsceneKey
		
		if key.cutscene_cam_id >= 0:
			camera.cutscene_camera = key.cutscene_cam_id
		awaiting_input = key.wait_for_player_input
		wait_timer = key.wait
		
		if key is CutsceneKeyText:
			camera.text_box.new_line(key.text)
		
		if key is CutsceneKeyPlayerInput:
			key.enable()
		
		#print(key.cutscene_cam_id, " ", key.text)
