
extends KinematicBody

export(NodePath) var player_controller_node_path
var player_controller

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
	
	pass

