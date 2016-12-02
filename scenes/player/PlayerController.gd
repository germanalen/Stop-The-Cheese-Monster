
extends Spatial


const PLAYER_POS_BOUND_SIZE = Vector2(60, 25)

export var forward_speed = 0



func _ready():
	set_process(true)
	
	set_fixed_process(true)


func get_player_pos():
	return get_node("Player").get_global_transform().origin


func _process(delta):
	# move forward
	translate(-get_transform().basis.z * forward_speed * delta)
	
	
	var player_pos = get_node("Player").get_translation()
	
	var camera = get_node("Camera")
	var camera_rotation = camera.get_rotation()
	camera_rotation.y = -player_pos.x / PLAYER_POS_BOUND_SIZE.width * 0.4
	camera.set_rotation(camera_rotation)
	
	
	if Input.is_action_pressed("shoot"):
		shoot()


func shoot():
	get_node("Player/Shooter").shoot()
	pass


func _fixed_process(delta):
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
	var wish_roll = -PI/6 * move_direction.x
	var wish_pitch = PI/5 * move_direction.y
	
	var roll = player.get_rotation().z
	var pitch = player.get_rotation().x
	
	var roll_pitch_lerp_rate = 10
	roll = lerp(roll, wish_roll, delta * roll_pitch_lerp_rate)
	pitch = lerp(pitch, wish_pitch, delta * roll_pitch_lerp_rate)
	
	player.set_rotation(Vector3(pitch, 0, roll))


func on_projectile_collide(damage):
	print("splash")
