
extends Spatial

var leg_upper
var wish_upper_quat

var leg_lower
var lower_global_basis

var global_node

func _ready():
	global_node = get_node("/root/global")
	
	leg_upper = get_node("LegUpper")
	leg_lower = get_node("LegUpper/LegLower")
	
	wish_upper_quat = Quat(leg_upper.get_transform().basis)
	lower_global_basis = leg_lower.get_global_transform().basis
	
	set_process(true)
	pass


func _process(delta):
	walking_animation()
	
	global_node.spatial_quat_slerp(leg_upper, wish_upper_quat, 4 * delta)
	
	var lower_global_transform = leg_lower.get_global_transform()
	lower_global_transform.basis = lower_global_basis
	leg_lower.set_global_transform(lower_global_transform)


export var walk_forward = false
func walking_animation():
	if animation_finished():
		walk_forward = !walk_forward
	
	var walk_y_period = PI/2
	if walk_forward:
		var quat_forward = Quat(leg_upper.get_transform().basis.y, walk_y_period/2)
		wish_upper_quat = quat_forward 
	else:
		var quat_back = Quat(leg_upper.get_transform().basis.y, -walk_y_period/2)
		var x_angle = -pow(sin((leg_upper.get_rotation().y + walk_y_period/2)*2), 2) * PI/3 + PI/18
#		print(rad2deg(x_angle))
		var quat_updown = Quat(leg_upper.get_transform().basis.x, x_angle)
		wish_upper_quat = quat_back * quat_updown



func animation_finished():
	return wish_upper_quat.dot(Quat(leg_upper.get_transform().basis)) > 0.99

