#extends Area2D
#
#@onready var ANT = $"%ANT"
#@onready var colision_shape := $"CollisionShape2D"
##@onready var bounds = get_node_or_null(_bounds)
#@onready var _bounds = ANT._bounds
#
#func _calculate_new_position(position: Vector2=Vector2.ZERO) -> Vector2:
#	var new_position := Vector2.ZERO
#	new_position.x = randf_range(ANT._bounds.position.x, ANT._bounds.end.x)
#	new_position.y = randf_range(ANT._bounds.position.y, ANT._bounds.end.y)
#
##	if (position - new_position).length() < 4.0*colision_shape.shape.get_radius():
##		return _calculate_new_position(position)
#
#	var radius = colision_shape.shape.get_radius()
#	var rect = Rect2(new_position-Vector2(radius, radius), 
#	Vector2(radius*2, radius*2)
#	)
#
#	return new_position
#
##func _physics_process(delta):
##	pass
#
#func _on_bonk_6_area_entered(area):
#	print("HIT: " + str(area))
#	position = _calculate_new_position(position)
#
#
#func _on_bonk_5_area_entered(area):
#	print("HIT: " + str(area))
#	position = _calculate_new_position(position)
#
#
#func _on_bonk_4_area_entered(area):
#	print("HIT: " + str(area))
#	position = _calculate_new_position(position)
#
#
#func _on_bonk_3_area_entered(area):
#	print("HIT: " + str(area))
#	position = _calculate_new_position(position)
#
#
#func _on_bonk_2_area_entered(area):
#	print("HIT: " + str(area))
#	position = _calculate_new_position(position)
#
#func _on_bonk_area_entered(area):
#	print("HIT: " + str(area))
#	position = _calculate_new_position(position)
