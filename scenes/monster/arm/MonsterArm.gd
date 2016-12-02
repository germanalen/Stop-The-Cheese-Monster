
extends RigidBody

export var flipped = false

var arm_upper
var arm_lower
var global_node


func _ready():
	global_node = get_node("/root/global")
	
	arm_upper = get_node("ArmUpper")
	arm_lower = get_node("ArmUpper/ArmLower")
	
	wish_upper_quat = Quat(arm_upper.get_transform().basis)
	wish_lower_quat = Quat(arm_lower.get_transform().basis)
	
	set_process(true)



var wish_upper_quat
var wish_lower_quat


func _process(delta):
	var arm_rotate_slerp_rate = 4
	
	global_node.spatial_quat_slerp(arm_upper, wish_upper_quat, arm_rotate_slerp_rate * delta)
	global_node.spatial_quat_slerp(arm_lower, wish_lower_quat, arm_rotate_slerp_rate * delta)


func wiggle():
	var wish_arm_quad_change_threshold = 0.999
	
	if wish_upper_quat.dot(Quat(arm_upper.get_transform().basis)) > wish_arm_quad_change_threshold:
		var wish_upper_y = -(rand_range(-PI/6, PI/5))
		var wish_upper_x = -(rand_range(0, PI/6))
		wish_upper_quat = Quat(arm_upper.get_transform().basis.y, wish_upper_y) * Quat(arm_upper.get_transform().basis.x, wish_upper_x)
	
	if wish_lower_quat.dot(Quat(arm_lower.get_transform().basis)) > wish_arm_quad_change_threshold:
		var wish_lower_y = -(rand_range(-PI/2.1, 0))
		wish_lower_quat = Quat(arm_lower.get_transform().basis.y, wish_lower_y)
	


func direct_at(point):
	var arm_upper_global_transform = arm_upper.get_global_transform()
	arm_upper_global_transform = arm_upper_global_transform.looking_at(point, Vector3(0, 1, 0))
	var arm_upper_transform = arm_upper.get_parent().get_global_transform().affine_inverse() * arm_upper_global_transform
	if flipped:
		arm_upper_transform.basis.x *= -1
	wish_upper_quat = Quat(arm_upper_transform.basis)
	
	wish_lower_quat = Quat(arm_lower.get_transform().basis.y,0)


func shoot():
	get_node("ArmUpper/ArmLower/Shooter").shoot()


var health = 10

func on_projectile_collide(damage):
	health -= damage
	
	if health <= 0:
		# crashes if we call fall_off directly
		call_deferred("fall_off")


func fall_off():
	var global_transform = get_global_transform()
	var new_parent = get_node("/root/Game/Other")
	get_parent().remove_child(self)
	new_parent.add_child(self)
	set_global_transform(global_transform)
	
	set_mode(MODE_RIGID)