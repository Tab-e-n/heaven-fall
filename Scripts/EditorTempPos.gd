extends Node2D


@export var enabled : bool = true


func _ready():
	if OS.has_feature("editor") and enabled:
		var node : Node2D = get_parent() as Node2D
		if node:
			node.global_position = global_position
	
	queue_free()
