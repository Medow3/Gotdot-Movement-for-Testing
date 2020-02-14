  
# Part of godot engine
extends KinematicBody2D

# Variable that can be changed
var accel = 6 				# How fast the player accelerates
var decel = 7				# How fast the player decelerates
var max_speed = 365			# Max speed the player can move
var min_speed = 0			# Minimum speed the player can move
var latency = 11			# How many frames of input latency. (effects movenemt and turning)
var min_turn_radius = 0.4	# The minimum turning radius (0 - 0.9. 0 = 180 degrees, 0.9 = crazy small angle)

var standstill_startup_latency = 200

# Misalanous variables
var velocity = 0
var latency_list = []
var movement: Vector2
var time_till_max_speed = (accel * 60.0) / max_speed
var setup_needed = true
var none_dir: Vector2
var drag_enabled = false
var standstill_startup_frame_counter = 0


# This function runs every frame
func _physics_process(delta):
	# runs once at the start of the program
	if setup_needed:
		setup()
		setup_needed = false
	
	#standstill_startup_check()
	
	# gets the mouse position, and bases movement off of it
	var new_position = get_global_mouse_position()
	movement = new_position - position;
	
	# Checks if the player is clicking. If so, accelerate, if not decelerate.
	# If the player is clicking, but the object is not moveing, also decelerate
	if drag_enabled:
		if movement != none_dir:
			accelerate(accel)
		else:
			decelerate(decel)
	else:
		decelerate(decel)
	
	# avoids the player moveing around slowly when not clicking
	normalize_low_vel()
	
	# normalizes (sets length to 1) the movement vector and applys the velocity to it
	if movement.length() > (velocity * delta):
		movement = velocity * delta * movement.normalized()
	
	#standstill_startup()
	
	#apply_min_turning_radius(delta)
	
	# applys the frame latency variable
	movement = apply_latency(movement)
	
	print(standstill_startup_frame_counter)
	
	# Apply movement
	move_and_collide(movement)


	
# accelerates the player (not past max_speed)
func accelerate(ammount):
	if velocity + ammount <= max_speed:
		velocity += ammount


# decelerates the player (not past min_speed)
func decelerate(ammount):
	if velocity - ammount >= min_speed:
			velocity -= ammount


# returns a boolean of wether the player is turning faster than the min_turning_radius
func min_turning_radius_check():
	var mouse_position = get_global_mouse_position()
	var line_player_mouse = (mouse_position - position).normalized()
	print(line_player_mouse.dot(movement))
	if line_player_mouse.dot(movement) > min_turn_radius:
    	return false
	else:
		return true


func apply_min_turning_radius(delta):
	if min_turning_radius_check():
		var angle = atan2(movement.y, movement.x)
		angle += 3.14159/4
		movement.x = cos(angle)
		movement.y = sin(angle)
		movement = velocity * delta * movement.normalized()


func standstill_startup_check():
	if movement == none_dir and drag_enabled and standstill_startup_frame_counter == 0:
		standstill_startup_frame_counter = standstill_startup_latency


func standstill_startup():
	if standstill_startup_frame_counter > 0:
		movement = none_dir
		standstill_startup_frame_counter -= 1
	
	


# avoids the player moveing around slowly when not clicking
func normalize_low_vel():
	if velocity < accel:
		velocity = 0


# applies the frame latency variable to have the player move to where the mouse was, so many frames ago.
func apply_latency(movement):
	latency_list.append(movement)
	if len(latency_list) > latency:
		latency_list.remove(0)
	return latency_list[0]


# One time startup function to initialize the latency_list variable that 
# tracks the movement of the player over the last so many frames.
func setup_latency_list():
	var empty_vector: Vector2
	for i in range(latency):
		latency_list.append(empty_vector)



# One time startup function. Prints time_till_max_speed in seconds, and runs setup_latency_list() function
func setup():
	setup_latency_list()
	print("time till max speed ", time_till_max_speed, " seconds")


# Gets click input of the mouse and changes the drag_enabled to true or false
# depending on whether the mouse is clicked or not.
func _input(event):
	if event is InputEventMouseButton:
		if drag_enabled:
			drag_enabled = false
		else:
			drag_enabled = true