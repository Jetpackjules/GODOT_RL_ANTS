extends Camera2D

const MOVE_SPEED = 1000
const MIN_ZOOM = 0.4
const MAX_ZOOM = 2
const ZOOM_FACTOR = 1.2

func _process(delta):
#	if Input.is_action_pressed("reset_camera"):
#		global_position = Vector2.ZERO
	if Input.is_action_pressed("left"):
		global_position += Vector2.LEFT * delta * MOVE_SPEED
	elif Input.is_action_pressed("right"):
		global_position += Vector2.RIGHT * delta * MOVE_SPEED    
	if Input.is_action_pressed("up"):
		global_position += Vector2.UP * delta * MOVE_SPEED
	elif Input.is_action_pressed("down"):
		global_position += Vector2.DOWN * delta * MOVE_SPEED
		
	global_position.x = max(0, global_position.x)
	global_position.y = max(0, global_position.y)


func _input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("zoom_in"):
			zoom *= ZOOM_FACTOR
		if event.is_action_pressed("zoom_out"):
			zoom /= ZOOM_FACTOR
	zoom.x = clamp(zoom.x, MIN_ZOOM, MAX_ZOOM)
	zoom.y = clamp(zoom.y, MIN_ZOOM, MAX_ZOOM)

