
extends KinematicBody

export(NodePath) var player_controller_node_path
var player_controller

onready var skeleton = get_node("Spiderbot/Armature/Skeleton")
onready var chest_bone_id = skeleton.find_bone("Chest")

func _ready():
	player_controller = get_node(player_controller_node_path)
	
	set_process(true)
	
	#get_node("Spiderbot/AnimationPlayer").get_animation("Walk").set_loop(true)
	#get_node("Spiderbot/AnimationPlayer").play_backwards("Walk")


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
	
	#idk why chest bone rotates twice as fast. Maybe it has smth to do with Blender.
	var chest_bone_transform = skeleton.get_bone_pose(chest_bone_id)
	chest_bone_transform.basis = Matrix3(Vector3(0, 0, 1), to_player_xz.angle()*0.5)
	skeleton.set_bone_pose(chest_bone_id, chest_bone_transform)