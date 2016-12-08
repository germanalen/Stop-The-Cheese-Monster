
extends KinematicBody

export(NodePath) var player_controller_node_path
var player_controller

onready var skeleton = get_node("Spiderbot/Armature/Skeleton")
onready var chest_bone_id = skeleton.find_bone("Chest")
onready var animation_tree_player = get_node("Spiderbot/AnimationTreePlayer")

func _ready():
	player_controller = get_node(player_controller_node_path)
	
	set_process(true)


func _process(delta):
	if Input.is_key_pressed(KEY_1):
		for arm in get_node("Arms").get_children():
			arm.shoot()
	
	if Input.is_key_pressed(KEY_Z):
		for arm in get_node("Arms").get_children():
			arm.wiggle()
	if Input.is_key_pressed(KEY_X):
		for arm in get_node("Arms").get_children():
			arm.direct_at(player_controller.get_player_pos())	
	
	
	# rotate chest towards the player
	var to_player_xyz = player_controller.get_player_pos() - get_transform().origin
	var to_player_xz = Vector2(to_player_xyz.x, to_player_xyz.z)
	
	get_node("Arms").set_rotation(Vector3(0, to_player_xz.angle(), 0))
	
	#idk why angle has to be multiplied by 0.5. Maybe it has smth to do with Blender.
	var right_left_ration = (to_player_xz.angle() * 0.5 + PI/2)/PI
	animation_tree_player.blend2_node_set_amount("Chest", right_left_ration)
	
	
	# Petals
	if get_node("Arms").get_child_count() == 0:
		animation_tree_player.transition_node_set_current("Petals", 1)


var health = 20
# Petals.on_projectile_collide
func on_projectile_collide(damage):
	if get_node("Arms").get_child_count() == 0:
		health -= damage
		
		if !alive():
			var idle_walk_blend = animation_tree_player.blend2_node_get_amount("IdleWalk")
			idle_walk_blend = lerp(idle_walk_blend, 0, 0.2)
			animation_tree_player.blend2_node_set_amount("IdleWalk", idle_walk_blend)


func alive():
	return health > 0
