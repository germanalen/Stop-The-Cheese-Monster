
extends KinematicBody

export(NodePath) var player_controller_node_path
onready var player_controller=  get_node(player_controller_node_path)

onready var skeleton = get_node("Spiderbot/Armature/Skeleton")
onready var chest_bone_id = skeleton.find_bone("Chest")
onready var animation_tree_player = get_node("Spiderbot/AnimationTreePlayer")

func _ready():
	set_process(true)
#	set_process_input(true)
	set_fixed_process(true)
#	for arm in get_node("Arms").get_children():
#		arm.on_projectile_collide(1000)


func _process(delta):
	ai_process(delta)
	
#	if Input.is_key_pressed(KEY_1):
#		for arm in get_node("Arms").get_children():
#			arm.shoot(current_velocity())
#	if Input.is_key_pressed(KEY_Z):
#		stop_shoot_pattern()
#		for arm in get_node("Arms").get_children():
#			arm.wiggle()
#	if Input.is_key_pressed(KEY_X):
#		stop_shoot_pattern()
#		for arm in get_node("Arms").get_children():
#			arm.direct_at(player_controller.get_player_pos())
#		turn_to_player(delta)
	
	shoot_pattern_process()
	
	
	if get_node("Arms").get_child_count() == 0:
		# Petals
		animation_tree_player.transition_node_set_current("Petals", 1)
#		if Input.is_key_pressed(KEY_1) && alive():
#			get_node("Petals/Shooter").look_at(player_controller.get_player_pos(), Vector3(0,1,0))
#			get_node("Petals/Shooter").shoot(current_velocity())
	
		# Lights color
		var material = get_node("Spiderbot/Armature/Skeleton/lights").get_material_override()
		var diffuse_color = material.get_parameter(FixedMaterial.PARAM_DIFFUSE)
		if alive():
			diffuse_color.v = float(health)/max_health * 0.5 + 0.5
		else:
			diffuse_color.v = lerp(diffuse_color.v, 0.1, delta * 8)
		material.set_parameter(FixedMaterial.PARAM_DIFFUSE, diffuse_color)
		var emission_color = material.get_parameter(FixedMaterial.PARAM_EMISSION)
		emission_color.v = diffuse_color.v
		material.set_parameter(FixedMaterial.PARAM_EMISSION, emission_color)

#func _input(event):
#	if event.type == InputEvent.KEY:
#		if event.pressed == true:
#			if event.scancode == KEY_0:
#				switch_idle_walking()
#			if event.scancode == KEY_2:
#				reset_shoot_pattern(lines_shoot_pattern_horizontal())
#			if event.scancode == KEY_3:
#				reset_shoot_pattern(lines_shoot_pattern_vertical())
#			if event.scancode == KEY_4:
#				reset_shoot_pattern(cross_shoot_pattern())
#			if event.scancode == KEY_5:
#				reset_shoot_pattern(spiral_shoot_pattern())


const max_health = 20
var health = max_health
# Petals.on_projectile_collide
func petals_on_projectile_collide(damage):
	if get_node("Arms").get_child_count() == 0:
		health -= damage
		
		if !alive():
			player_controller.on_player_won()
			stop_walking()
			get_node("SmokeParticles").set_emitting(true)
			get_node("ExplosionParticles").set_emitting(true)


func alive():
	return health > 0


export var walking_speed = 200
onready var walking_velocity = Vector3(0, 0, -walking_speed)
var wish_walking = 1
var walking = 1
func _fixed_process(delta):
	walking = lerp(walking, wish_walking, 10 * delta)
	animation_tree_player.blend2_node_set_amount("IdleWalk", walking)
	
	translate(current_velocity() * delta)

func switch_idle_walking():
	wish_walking = 1 - wish_walking

func stop_walking():
	wish_walking = 0

func current_velocity():
	return walking_velocity * walking


func turn_to_player(delta):
	# rotate chest towards the player
	var to_player_xyz = player_controller.get_player_pos() - get_transform().origin
	var wish_rotation = Vector2(to_player_xyz.x, to_player_xyz.z).angle()
	
	var rotation = get_node("Arms").get_rotation().y
	rotation = lerp(rotation, wish_rotation, delta * 5)
	
	get_node("Arms").set_rotation(Vector3(0, rotation, 0))
	
	#idk why angle has to be multiplied by 0.5. Maybe it has smth to do with Blender.
	var right_left_ration = (rotation * 0.5 + PI/2)/PI
	animation_tree_player.blend2_node_set_amount("Chest", right_left_ration)


func reset_shoot_pattern(points):
	shoot_pattern = points
	shoot_pattern_index = 0



var shoot_pattern = [[],[],[],[]]
var shoot_pattern_index = 0
func shoot_pattern_process():
	if shoot_pattern_index < shoot_pattern[0].size():
		var arms = get_node("Arms").get_children()
		var arms_can_shoot = true
		for i in range(arms.size()):
			var point = shoot_pattern[i][floor(shoot_pattern_index)][0]
			var point3 = Vector3()
			point3.x = point.x * player_controller.PLAYER_POS_BOUND_SIZE.width
			point3.y = point.y * player_controller.PLAYER_POS_BOUND_SIZE.height
			point3 += player_controller.get_global_transform().origin
			arms[i].direct_at(point3)
			if !arms[i].can_shoot():
				arms_can_shoot = false
				break
		
		if shoot_pattern_index < 1:
			# to direct arms to starting position
			shoot_pattern_index += 0.025
		elif arms_can_shoot:
			for i in range(arms.size()):
				if shoot_pattern[i][floor(shoot_pattern_index)][1]:
					arms[i].shoot(current_velocity())
			shoot_pattern_index += 1


func stop_shoot_pattern():
	shoot_pattern = [[],[],[],[]]

func shoot_pattern_finished():
	return shoot_pattern_index >= shoot_pattern[0].size()


func lines_shoot_pattern_horizontal(midpoint_y=0):
	var points = [[],[],[],[]]
	
	for i in range(20):
		var x = (i/19.0 - 0.5) * 1.5
		points[0].append([Vector2(x, midpoint_y + 0.4), true])
		points[1].append([Vector2(-x, midpoint_y + 0.2), true])
		points[2].append([Vector2(x, midpoint_y -0.4), true])
		points[3].append([Vector2(-x, midpoint_y -0.2), true])
	
	return points

func lines_shoot_pattern_vertical(midpoint_x=0):
	var points = [[],[],[],[]]
	
	for i in range(15):
		var y = (i/14.0 - 0.5) * 1.5
		points[0].append([Vector2(midpoint_x + 0.05, y), true])
		points[1].append([Vector2(midpoint_x - 0.05, y), true])
		points[2].append([Vector2(midpoint_x + 0.2, -y), true])
		points[3].append([Vector2(midpoint_x - 0.2, -y), true])
	
	return points

func cross_shoot_pattern():
	var points = [[],[],[],[]]
	
	var length_x = 5
	var length_y = 5
	
	for i in range(length_x):
		for j in range(length_y):
			var x = (i/(length_x-1.0))/2
			var y = (i/(length_y-1.0))/2
			points[0].append([Vector2(x, y), true])
			points[1].append([Vector2(-x, y), true])
			points[2].append([Vector2(x, -y), true])
			points[3].append([Vector2(-x, -y), true])
	return points

func spiral_shoot_pattern(length = 60, begin_radius = 0.1, end_radius = 1):
	var points = [[],[],[],[]]
	
	var radius = begin_radius
	var radius_increment = (end_radius - begin_radius) / length
	
	for i in range(length):
		radius += radius_increment
		var angle = (i*PI/180) * (360/length)
		points[0].append([Vector2(sin(angle),cos(angle)) * radius, true])
		points[1].append([Vector2(sin(angle+PI/2),cos(angle+PI/2)) * radius, true])
		points[2].append([Vector2(sin(angle+PI),cos(angle+PI)) * radius, true])
		points[3].append([Vector2(sin(angle+PI*1.5),cos(angle+PI*1.5)) * radius, true])
	
	return points


var attacking = false
func ai_process(delta):
	if !alive():
		return
	
	var ai_timer = get_node("AITimer")
	if player_controller.player_alive():
		if attacking:
			if shoot_pattern_finished():
				attacking = false
				ai_timer.start()
		else:
			if ai_timer.get_time_left() <= 0:
				attacking = true
				
				var pattern_num = randi() % 4
				if pattern_num == 0:
					reset_shoot_pattern(lines_shoot_pattern_horizontal())
				if pattern_num == 1:
					reset_shoot_pattern(lines_shoot_pattern_vertical())
				if pattern_num == 2:
					reset_shoot_pattern(cross_shoot_pattern())
				if pattern_num == 3:
					reset_shoot_pattern(spiral_shoot_pattern())
			for arm in get_node("Arms").get_children():
				arm.wiggle()
		if get_node("Arms").get_child_count() == 0:
				turn_to_player(delta)
				get_node("Petals/Shooter").look_at(player_controller.get_player_pos(), Vector3(0,1,0))
				get_node("Petals/Shooter").shoot(current_velocity())
	else:
		wish_walking = lerp(wish_walking, 0, delta * 0.3)
		if wish_walking < 0.4:
			wish_walking = 0
		stop_shoot_pattern()
		for arm in get_node("Arms").get_children():
			arm.wiggle()
			if wish_walking < 0.2:
				arm.shoot(current_velocity())