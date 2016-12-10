
extends KinematicBody

export(NodePath) var player_controller_node_path
onready var player_controller=  get_node(player_controller_node_path)

onready var skeleton = get_node("Spiderbot/Armature/Skeleton")
onready var chest_bone_id = skeleton.find_bone("Chest")
onready var animation_tree_player = get_node("Spiderbot/AnimationTreePlayer")

func _ready():
	set_process(true)
	set_process_input(true)
	set_fixed_process(true)
	#for arm in get_node("Arms").get_children():
	#	arm.on_projectile_collide(1000)


func _process(delta):
	if Input.is_key_pressed(KEY_1):
		for arm in get_node("Arms").get_children():
			arm.shoot(current_velocity())
	if Input.is_key_pressed(KEY_Z):
		for arm in get_node("Arms").get_children():
			arm.wiggle()
	if Input.is_key_pressed(KEY_X):
		for arm in get_node("Arms").get_children():
			arm.direct_at(player_controller.get_player_pos())
	
	shoot_pattern_process()
	
	# Petals
	if get_node("Arms").get_child_count() == 0:
		animation_tree_player.transition_node_set_current("Petals", 1)
		if Input.is_key_pressed(KEY_1) && alive():
			get_node("Petals/Shooter").look_at(player_controller.get_player_pos(), Vector3(0,1,0))
			get_node("Petals/Shooter").shoot(current_velocity())


func _input(event):
	if event.type == InputEvent.KEY:
		if event.pressed == true:
			if event.scancode == KEY_2:
				reset_shoot_pattern(lines_shoot_pattern())
			if event.scancode == KEY_0:
				switch_idle_walking()


var health = 20
# Petals.on_projectile_collide
func petals_on_projectile_collide(damage):
	if get_node("Arms").get_child_count() == 0:
		health -= damage
		
		if !alive():
			player_controller.on_player_won()
			stop_walking()


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

func turn_to_player(delta):
	# rotate chest towards the player
	var to_player_xyz = player_controller.get_player_pos() - get_transform().origin
	var to_player_xz = Vector2(to_player_xyz.x, to_player_xyz.z)
	
	get_node("Arms").set_rotation(Vector3(0, to_player_xz.angle(), 0))
	
	#idk why angle has to be multiplied by 0.5. Maybe it has smth to do with Blender.
	var right_left_ration = (to_player_xz.angle() * 0.5 + PI/2)/PI
	animation_tree_player.blend2_node_set_amount("Chest", right_left_ration)


func reset_shoot_pattern(points):
	shoot_pattern = points
	shoot_pattern_index = 0


var shoot_pattern = [[],[],[],[]]
var shoot_pattern_index = 0
var shoot_pattern_subindex = 0
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
		
		if arms_can_shoot:
			for i in range(arms.size()):
				if shoot_pattern[i][floor(shoot_pattern_index)][1]:
					arms[i].shoot(current_velocity())
			shoot_pattern_index += 1


func lines_shoot_pattern():
	var points = [[],[],[],[]]
	
	for i in range(60):
		var point = [Vector2((i/59.0 - 0.5), 0.5)*1.2, true]
		points[0].append(point)
		points[2].append(point)
		points[1].append(point)
		points[3].append(point)
	
	return points


func current_velocity():
	return walking_velocity * walking