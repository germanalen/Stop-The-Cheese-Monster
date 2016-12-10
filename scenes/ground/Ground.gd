extends Spatial

export(NodePath) var player_controller_node_path
onready var player_controller = get_node(player_controller_node_path)

onready var mesh1 = get_node("GroundMesh")
onready var mesh2 = get_node("GroundMesh 2")

func _ready():
	set_process(true)


func _process(delta):
	var mesh_length = 20030
	
	var player_z = player_controller.get_player_pos().z
	var mesh1_z = mesh1.get_global_transform().origin.z
	var mesh2_z = mesh2.get_global_transform().origin.z
	
	var next_mesh_pos = (floor(player_z/mesh_length)) * mesh_length
	
	if player_z < mesh1_z && mesh1_z < mesh2_z:
		mesh2_z = next_mesh_pos
	if player_z < mesh2_z && mesh2_z < mesh1_z:
		mesh1_z = next_mesh_pos
	
	var mesh1_global_transform = mesh1.get_global_transform()
	var mesh2_global_transform = mesh2.get_global_transform()
	mesh1_global_transform.origin.z = mesh1_z
	mesh2_global_transform.origin.z = mesh2_z
	mesh1.set_global_transform(mesh1_global_transform)
	mesh2.set_global_transform(mesh2_global_transform)
	
	pass
