extends Area2D


@export var level : String = ""
@export_enum("left", "right") var direction : int = 0


@onready var time_text : TimeShowcase = $time as TimeShowcase


var time : float = -1.0
var activate_late : bool = false

var active : bool = false


func _ready():
	active = time_text.show_time(level)
	#if not level.is_empty() and Global.savefile.has(level):
		#if Global.savefile[level][Global.LEVEL_BEATEN]:
			#time = Global.savefile[level][Global.LEVEL_TIME]
			#if time != -1.0:
				#time_text.text = "Best: " + Global.float_to_time(time)
			#else:
				#time_text.text = "Best: No time set"
			#active = true
	
	if not active:
		deactivate()
	else:
		if direction == 1:
			$not_interested.position = $left.position
		else:
			$not_interested.position = $right.position
		if Global.use_saved_pos:
			deactivate()
		else:
			activate()


func _physics_process(_delta):
	if not active:
		return
	if activate_late:
		activate_late = false
		$coll_left.set_deferred("disabled", direction == 1)
		$coll_right.set_deferred("disabled", direction == 0)
		$not_interested.set_deferred("monitoring", true)
		$not_interested.set_deferred("monitorable", true)
	if Input.is_action_just_pressed("reset"):
		call_deferred("activate")


func activate():
	visible = true
	activate_late = true
	$left.visible = direction == 0
	$right.visible = direction == 1
	time_text.visible = true


func deactivate():
	visible = false
	$coll_left.set_deferred("disabled", true)
	$coll_right.set_deferred("disabled", true)
	$left.visible = false
	$right.visible = false
	time_text.visible = false
	$not_interested.set_deferred("monitoring", false)
	$not_interested.set_deferred("monitorable", false)


func _on_body_entered(body):
	if body is Player and active:
		body.speedrun_timer = 0.0
		#print(body.global_position)
		deactivate()


func _on_not_interested_entered(body):
	if body is Player:
		deactivate()

func perma_deactivate():
	active = false
	deactivate()
