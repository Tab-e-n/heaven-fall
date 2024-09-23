extends Node2D
class_name TextBox


@onready var label : Label = $label

var active : bool = false


func _ready():
	visible = active


func _physics_process(delta):
	pass
	#if active:
		#if Input.is_action_just_pressed("reset"):
			#disable()


func new_line(text : String):
	label.text = text
	if text.is_empty():
		disable()
	elif not active:
		enable()


func enable():
	active = true
	visible = true


func disable():
	active = false
	visible = false

