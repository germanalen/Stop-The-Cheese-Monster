
extends Spatial


const PLAYER_POS_BOUND_SIZE = Vector2(60, 25)

export var forward_speed = 0
onready var forward_velocity = Vector3(0, 0, -forward_speed)

onready var camera_player_offset = get_node("Camera").get_translation() - get_node("Player").get_translation()

func _ready():
	set_process(true)
	
	set_fixed_process(true)


func get_player_pos():
	return get_node("Player").get_global_transform().origin


func _process(delta):
	var player_pos = get_node("Player").get_translation()
	
	var camera = get_node("Camera")
	var camera_rotation = camera.get_rotation()
	camera_rotation.y = -player_pos.x / PLAYER_POS_BOUND_SIZE.width * 0.4
	camera.set_rotation(camera_rotation)
	
	
	if Input.is_action_pressed("shoot"):
		shoot()


func shoot():
	get_node("Player/Shooter").shoot(forward_velocity)
	pass


var wish_roll = 0
var wish_pitch = 0


func _fixed_process(delta):
	if player_alive():
		if player_won:
			player_won_process(delta)
		else:
			player_playing_process(delta)
	else:
		player_lost_process(delta)
	
	
	var player = get_node("Player")
	
	var roll = player.get_rotation().z
	var pitch = player.get_rotation().x
	
	var roll_pitch_lerp_rate = 10
	roll = lerp(roll, wish_roll, delta * roll_pitch_lerp_rate)
	pitch = lerp(pitch, wish_pitch, delta * roll_pitch_lerp_rate)
	
	player.set_rotation(Vector3(pitch, 0, roll))


func player_playing_process(delta):
	# move forward
	translate(forward_velocity * delta)
	
	
	var player = get_node("Player")
	
	# movement
	var wish_move_direction = Vector2(0, 0)
	
	if Input.is_action_pressed("move_up"):
		wish_move_direction += Vector2(0, 1)
	if Input.is_action_pressed("move_down"):
		wish_move_direction += Vector2(0, -1)
	if Input.is_action_pressed("move_left"):
		wish_move_direction += Vector2(-1, 0)
	if Input.is_action_pressed("move_right"):
		wish_move_direction += Vector2(1, 0)
	
	wish_move_direction = wish_move_direction.normalized()
	
	# delta_pos, move_direction calculation
	var SPEED = 25
	var wish_delta_pos = wish_move_direction * SPEED * delta
	var pos = player.get_translation()
	
	
	var move_direction = Vector2(0, 0)
	if (-PLAYER_POS_BOUND_SIZE.width/2 < pos.x + wish_delta_pos.x) && (pos.x + wish_delta_pos.x < PLAYER_POS_BOUND_SIZE.width/2):
		move_direction.x = wish_move_direction.x
	if (-PLAYER_POS_BOUND_SIZE.height/2 < pos.y + wish_delta_pos.y) && (pos.y + wish_delta_pos.y < PLAYER_POS_BOUND_SIZE.height/2):
		move_direction.y = wish_move_direction.y
	
	var delta_pos = move_direction * SPEED * delta
	player.move(Vector3(delta_pos.x, delta_pos.y, 0))
	
	# Roll, pitch calculation
	wish_roll = -PI/6 * move_direction.x
	wish_pitch = PI/5 * move_direction.y
	


var player_lost_velocity_y = 0
func player_lost_process(delta):
	player_lost_velocity_y += -40 * delta
	
	var delta_x = wish_roll * (-10) * delta
	var delta_y = player_lost_velocity_y * delta
	var delta_z = forward_velocity.z * delta
	
	# I am sorry. This is my first 3d game. Giving collision shape to ground didn't work(((
	if get_node("../Ground").get_global_transform().origin.y < get_player_pos().y:
		get_node("Player").move(Vector3(delta_x, delta_y, delta_z))
	
	wish_pitch = -PI/5
	
	var camera = get_node("Camera")
	var camera_translation = camera.get_translation();
	var wish_camera_translation = get_node("Player").get_translation() + camera_player_offset	
	camera_translation.x = lerp(camera_translation.x, wish_camera_translation.x, delta)
	camera_translation.y = lerp(camera_translation.y, wish_camera_translation.y, 5 * delta)
	camera_translation.z = lerp(camera_translation.z, wish_camera_translation.z, 10 * delta)
	camera.set_translation(camera_translation)


var player_won = false
var player_won_velocity_y = 0
func player_won_process(delta):
	player_won_velocity_y += 20 * delta
	
	var delta_x = 0
	var delta_y = player_won_velocity_y * delta
	var delta_z = forward_velocity.z * delta
	
	get_node("Player").move(Vector3(delta_x, delta_y, delta_z))
	
	wish_roll = 0
	wish_pitch = PI/10
	
	var camera = get_node("Camera")
	var camera_translation = camera.get_translation();
	var wish_camera_translation = get_node("Player").get_translation() + camera_player_offset	
	camera_translation.x = lerp(camera_translation.x, wish_camera_translation.x, delta)
	camera_translation.y = lerp(camera_translation.y, wish_camera_translation.y, 5 * delta)
	camera_translation.z = lerp(camera_translation.z, wish_camera_translation.z, 5 * delta)
	#camera.set_translation(camera_translation)
	
	var camera_rotation = camera.get_rotation()
	camera_rotation.y = 0
	camera.set_rotation(camera_rotation)

func on_player_won():
	player_won = true


var health = 10

func on_projectile_collide(damage):
	health -= damage

func player_alive():
	return health > 0
	#return false