
extends KinematicBody

func on_projectile_collide(damage):
	get_parent().petals_on_projectile_collide(damage)