
extends Spatial


export(Mesh) var mesh
export(Shape) var shape
export var particles_size = 1.0
export(String) var shoot_sample_name
export(String) var hit_sample_name
onready var sample_player = get_node("/root/Game/SamplePlayer")

export var period = 1.0
var period_timer

export var damage = 1

export var projectile_lifetime = 10

export var relative_speed = 50

export(int, FLAGS) var collision_layers = 1
export(int, FLAGS) var collision_mask = 1
# projectiles destruct on collision with following bodies
export(int, FLAGS) var destruct_mask = 0

func _ready():
	period_timer = get_node("PeriodTimer")
	period_timer.set_wait_time(period)
	
	var particles = get_node("Particles")
	particles.set_material(mesh.surface_get_material(0))
	particles.set_variable(Particles.VAR_INITIAL_SIZE, particles_size)
	particles.set_variable(Particles.VAR_FINAL_SIZE, particles_size)

func create_projectile():
	var projectile = RigidBody.new()
	
	projectile.set_layer_mask(collision_layers)
	projectile.set_collision_mask(collision_mask)
	projectile.set_gravity_scale(0)
	
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
		
		var particle = get_node("Particles")
		var particle_global_transform = particle.get_global_transform()
		particle_global_transform.origin = projectile.get_global_transform().origin
		particle.set_global_transform(particle_global_transform)
		particle.set_emitting(true)
		
		sample_player.play(hit_sample_name)
	if body.get_layer_mask() & destruct_mask != 0:
		projectile.queue_free()


func shoot(parent_velocity):
	if period_timer.get_time_left() != 0:
		return
	period_timer.start()
	
	var projectile_parent = get_node("/root/Game/Other")
	var projectile = create_projectile()
	projectile.set_transform(projectile_parent.get_global_transform().affine_inverse() * get_global_transform())
	projectile_parent.add_child(projectile)
	projectile.set_linear_velocity(parent_velocity + projectile.get_transform().basis.z * (-relative_speed))
	
	sample_player.play(shoot_sample_name)


