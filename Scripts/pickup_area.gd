extends Area2D


var pickups : Array = []


func _on_body_entered(body):
	if body is Pickup:
		pickups.append(body)


func _on_body_exited(body):
	if body is Pickup:
		pickups.erase(body)


func closest_pickup() -> Pickup:
	var min_distance : float = 65535
	var closest : Pickup = null
	for pickup in pickups:
		var distance = global_position.distance_to(pickup.global_position)
		if min_distance > distance:
			min_distance = distance
			closest = pickup
	#print(closest, " ", pickups)
	return closest
