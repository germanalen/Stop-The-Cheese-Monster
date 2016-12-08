
extends Spatial


export(Mesh) var mesh
export(Shape) var shape

export var period = 1.0
var period_timer

export var damage = 1

export var projectile_lifetime = 10

export var speed = 50

export(int, FLAGS) var collision_layers = 1
export(int, FLAGS) var collision_mask = 1
# projectiles destruct on collision with following bodies
export(int, FLAGS) var destruct_mask = 0

func _ready():
	period_timer = get_node("PeriodTimer")
	period_timer.set_wait_time(period)


func create_projectile():
	var projectile = RigidBody.new()
	
	projectile.set_layer_mask(collision_layers)
	projectile.set_collision_mask(collision_mask)
	
	var mesh_instance = MeshInstance.new()
	mesh_instance.set_mesh(mesh)
	projectile.add_child(mesh_instance)
	
	projectile.add_shape(shape)
	for i in range(projectile.get_shape_count()):
		projectile.set_shape_as_trigger(i, true)
		pass
	
	var lifetime_timer = Timer.new()
	lifetime_timer.set_wait_time(projectile_lifetime)
	lifetime_timer.set_one_shot(true)
	lifetime_timer.set_autostart(true)
	projectile.add_child(lifetime_timer)
	
	lifetime_timer.connect("timeout", projectile, "queue_free")
	
	projectile.set_contact_monitor(true)
	projectile.set_max_contacts_reported(1)
	projectile.connect("body_enter", self, "projectile_on_body_enter", [projectile])
	
	
	return projectile


func projectile_on_body_enter(body, projectile):
	if body.has_method("on_projectile_collide"):
		body.on_projectile_collide(damage)
	if body.get_layer_mask() & destruct_mask != 0:
		projectile.queue_free()


func shoot():
	if period_timer.get_time_left() != 0:
		return
	period_timer.start()
	
	var projectile_parent = get_node("/root/Game/Other")
	var projectile = create_projectile()
	projectile.set_transform(projectile_parent.get_global_transform().affine_inverse() * get_global_transform())
	projectile_parent.add_child(projectile)
	projectile.set_linear_velocity(-projectile.get_transform().basis.z * speed)
	
	pass


