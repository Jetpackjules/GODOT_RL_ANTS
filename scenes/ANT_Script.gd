extends CharacterBody2D
var marker
#var velocity : Vector2 = Vector2()
@export var speed := 500
@export var friction = 1
#0.18
var _velocity := Vector2.ZERO
var _action = Vector2.ZERO
var reward = 0

#---------------------------------------------------------SCRIPT FOR RL AGENTS:
const pad = 50
const WIDTH = 360
const HEIGHT = 250

@export var _bounds := Rect2(pad,pad,WIDTH-2*pad,HEIGHT-2*pad)
	
var _heuristic: String = "human"
var done: bool = false

var n_steps = 0
var MAX_STEPS = 2000
var needs_reset: bool = false
#var reward = 0.0
var food = 0
# example actions
var move_action
var turn_action
var jump_action

@onready var leaf = $"../Leaf"
@onready var raycast_sensor = $"RaycastSensor2D"
@onready var SCORE = $"../score_label"
@onready var walls := $"../walls"
#@onready var walls := $"../Walls"
@onready var colision_shape := $"CollisionShape2D"
var leaf_just_entered = false
var best_leaf_distance = 10000.0
var leaf_count = 0
var deaths = 0.1

func _calculate_new_position(position: Vector2=Vector2.ZERO) -> Vector2:
	var new_position := Vector2.ZERO
	new_position.x = randf_range(_bounds.position.x, _bounds.end.x)
	new_position.y = randf_range(_bounds.position.y, _bounds.end.y)
	
	if (position - new_position).length() < 9.0*colision_shape.shape.get_radius():
		return _calculate_new_position(position)
		
	var radius = colision_shape.shape.get_radius()
	var rect = Rect2(new_position-Vector2(radius, radius), 
	Vector2(radius*2, radius*2)
	)
	for wall in walls.get_children():
		var cr = wall.get_node("ColorRect")
		var rect2 = Rect2(cr.get_position()+wall.position, cr.get_size())
		if rect.intersects(rect2):
			return _calculate_new_position()

	var cr = leaf.get_node("CollisionShape2D")
	var rect2 = Rect2(cr.get_position()+leaf.position, cr.shape.extents)
	if rect.intersects(rect2):
		return _calculate_new_position()

	return new_position
		
		
func spawn_leaf():
#	leafPath.progress_ratio += 0.3;
#	leaf._speed += 25
	leaf.position = _calculate_new_position(position)
	best_leaf_distance = position.distance_to(leaf.position)


#-----------------------------------------------------
#func round_to_dec(num, digit):
#	return round(num * pow(10.0, digit)) / pow(10.0, digit)

func _ready():
	raycast_sensor.activate()
	reset()

func _physics_process(delta: float) -> void:
#	print("VEL: " + str(velocity))
	SCORE.text = "reward: " + str(reward, 3)
	# + " | K/D: " + str(round_to_dec(leaf_count/deaths, 2))
#	SCORE.text = "LEAFS: " + str(leaf_count) + "|| DEATHS: " + str(deaths)
#	print("reward: " + str(reward))
		
	n_steps +=1
#	print("-----------------------------------STEPS: " + str(n_steps))

#	print(n_steps)
	if n_steps >= MAX_STEPS:
		print("MAX STEPS REACHED... RESETTING")
		done = true
		needs_reset = true

	if needs_reset:
		needs_reset = false
		reset()
		return
		
	var direction = get_direction()
	if direction.length() > 1.0:
		direction = direction.normalized()
	# Using the follow steering behavior.
	var target_velocity = direction * speed
	_velocity += (target_velocity - _velocity) * friction
	set_velocity(_velocity)
#	move_and_collide(_velocity/90)
	move_and_slide()
	_velocity = velocity
	rotation = velocity.angle()+1.55
	
	if Input.is_action_just_pressed("r_key"):
		print("Resetting from R key")
		reset()
	#added code!!!
	update_reward()


func get_direction():
	if done:
		_velocity = Vector2.ZERO
		return Vector2.ZERO
		
	if _heuristic == "model":
		return _action
		
	var direction := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	) 
	return direction
	

func reset() -> void:
	# The reset logic e.g reset if a player dies etc, reset health, ammo, position, etc ...
	print("RESET TIME BABYYYYY")
#	food = 0
	needs_reset = false
#	leaf_count = 0
#	leaf._speed = 250
	_velocity = Vector2.ZERO
	_action = Vector2.ZERO
	
#	rotation = 0
	position = _calculate_new_position()
#	spawn_leaf()
	
	best_leaf_distance = position.distance_to(leaf.position)
	n_steps = 0 


func reset_if_done() -> void:
	if done:
		print ("RESETTING BECAUSE... Done?")
		reset()

func zero_reward() -> void:
	reward = 0.0
	leaf_count = 0
	deaths = 0.1
	print("Zeroing reward")
	#COMMENTED  
	
	
func get_obs():
	var relative = leaf.position - position
	var distance = relative.length() / 1500.0
	relative = relative.normalized()
	var result := []
#	result.append(food)
	result.append(((position.x / WIDTH)-0.5) * 2)
	result.append(((position.y / HEIGHT)-0.5) * 2)
	result.append(relative.x)
	result.append(relative.y)
	result.append(distance)
	var raycast_obs = raycast_sensor.get_observation()
	result.append_array(raycast_obs)
	
#	print("OBS OUT:")
#	print("OBS OUT LENGTH: " + str(len(result)))
#	result = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
#	print(result)
	return {
		"obs": result
	}

func update_reward():
#	print("REWARD: " + str(reward))
	food -= 0.01
	reward -= 0.01
	reward += shaping_reward()


func get_reward():
#	# What behavior do you want to reward, kills? penalties for death, key waypoints
#	reward += food
	return reward*10

func shaping_reward():
	# can a sparse reward like kills, death be broken down into denser rewards such as hits taken/given, or distance from the target
	var s_reward = 0.0
	
#	COMMENTING OUT:
	var leaf_distance = position.distance_to(leaf.position)

	if leaf_distance < best_leaf_distance:
		s_reward += best_leaf_distance - leaf_distance
		best_leaf_distance = leaf_distance
		
	s_reward /= 100.0
#	print(s_reward)
	return s_reward


func set_heuristic(heuristic: String) -> void:
	# sets the heuristic from "human" or "model" nothing to change here
	self._heuristic = heuristic
	
func get_obs_size() -> int:
	# nothing to change here
	return len(get_obs())

func get_obs_space() -> Dictionary:
	# typs of obs space: box, discrete, repeated (for variable length observations)
	# Example observation space
	return {
		"obs": {
			"size": [len(get_obs()["obs"])],
			"space": "box"
				}
				}

func get_action_space() -> Dictionary:
	# Define the action space of you agent, below is an example, GDRL allows for discrete and continuous state spaces (assuming the RL algorithm allows it)
	# Example action space
	# SB3 does not allow for more than one values in action space
	return {
		"move" : {
			"size": 2,
			"action_type": "continuous"
				}
				}

func get_done() -> bool:
	# nothing to change here
	return done
	
func set_done_false():
	done = false

func set_action(action: Dictionary) -> void:
	# reads off the actions sent from the RL model to the agent
	# the keys here should match the dictionary keys in the "get_action_space" function
	_action.x = action["move"][0]
	_action.y = action["move"][1]
	
func leaf_collected():
	leaf_just_entered = true
	leaf_count += 1
	food += 10
	reward += 10
	spawn_leaf()
	
	
func _on_LEAF_body_entered(body):
	print("LEAFED, boi")
	leaf_collected()
	

func _on_bonk_body_entered(body):
	done = true
	deaths += 1
	reward -= 5
	reset()

#	position = _calculate_new_position()
