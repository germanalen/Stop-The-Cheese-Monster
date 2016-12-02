
extends KinematicBody

func on_projectile_collide(damage):
	get_parent().on_projectile_collide(damage)


