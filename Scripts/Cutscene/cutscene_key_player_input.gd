extends CutsceneKey
class_name CutsceneKeyPlayerInput


enum {TYPE_OFF, TYPE_TELEPORT, TYPE_WALK}

const FUDGE_RANGE : float = 3


@export_enum("Off", "Teleport", "Walking") var move_player_type : int = TYPE_OFF
@export var goto_pos : Vector2 = Vector2(0, 0)
@export var teleport_player_to_pos_after : float = 256

var active : bool = false
var tele_timer : float = 0


@onready var player : Player = GameCamera.player


func _physics_process(delta):
	if active:
		tele_timer -= delta
		if tele_timer <= 0:
			disable()
		
		if move_player_type == TYPE_WALK:
			var difference = goto_pos - player.position
			
			player.direction = sign(difference.x)
			
			if abs(difference.x) < FUDGE_RANGE and abs(difference.y) < FUDGE_RANGE:
				disable()


func enable():
	match(move_player_type):
		TYPE_OFF:
			player.clear_input()
		TYPE_TELEPORT:
			player.position = goto_pos
		_:
			active = true
			tele_timer = teleport_player_to_pos_after


func disable():
	active = false
	player.position = goto_pos
	player.clear_input()
