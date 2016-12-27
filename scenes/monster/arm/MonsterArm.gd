
extends KinematicBody

export var flipped = false

var arm_upper
var arm_lower
var global_node

# material should be "made unique" in each instance of MonsterArm
export(FixedMaterial) var material
var color

func _ready():
	global_node = get_node("/root/global")
	
	arm_upper = get_node("ArmUpper")
	arm_lower = get_node("ArmUpper/ArmLower")
	
	color = material.get_parameter(FixedMaterial.PARAM_DIFFUSE)
	arm_upper.get_node("InnerMesh").set_material_override(material)
	arm_lower.get_node("InnerMesh").set_material_override(material)
	
	
	wish_upper_quat = Quat(arm_upper.get_transform().basis)
	wish_lower_quat = Quat(arm_lower.get_transform().basis)
	
	set_process(true)
	set_fixed_process(true)
	
	if flipped:
		var shooter = get_node("ArmUpper/ArmLower/Shooter")
		shooter.set_scale(Vector3(-1, 1, 1))
		shooter.rotate_z(PI)


var wish_upper_quat
var wish_lower_quat


func _process(delta):
	if alive():
		var arm_rotate_slerp_rate = 4
		
		global_node.spatial_quat_slerp(arm_upper, wish_upper_quat, arm_rotate_slerp_rate * delta)
		global_node.spatial_quat_slerp(arm_lower, wish_lower_quat, arm_rotate_slerp_rate * delta)
	
	if alive():
		color.v = float(health)/max_health * 0.5 + 0.5
		material.set_parameter(FixedMaterial.PARAM_DIFFUSE, color)
	else:
		color.v = lerp(color.v, 0, delta * 8)
		material.set_parameter(FixedMaterial.PARAM_DIFFUSE, color)
	

func _fixed_process(delta):
	if !alive():
		fall_process(delta)


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


func shoot(parent_velocity):
	get_node("ArmUpper/ArmLower/Shooter").shoot(parent_velocity)


const max_health = 10
var health = max_health

func on_projectile_collide(damage):
	health -= damage
	
	if !alive():
		# crashes if we call fall_off directly
		call_deferred("fall_off")


func alive():
	return health > 0

var fall_velocity_y = 0
func fall_process(delta):
	fall_velocity_y += -40 * delta
	var delta_y = fall_velocity_y * delta
	move(Vector3(0, delta_y, 0))

func fall_off():
	var global_transform = get_global_transform()
	var new_parent = get_node("/root/Game/Other")
	get_parent().remove_child(self)
	new_parent.add_child(self)
	set_global_transform(global_transform)
	
	get_node("ArmUpper").set_layer_mask(0)
	get_node("ArmUpper/ArmLower").set_layer_mask(0)
	
	get_node("/root/Game/SamplePlayer").play("arm1")



func can_shoot():
	return get_node("ArmUpper/ArmLower/Shooter/PeriodTimer").get_time_left() == 0