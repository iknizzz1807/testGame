extends Effect
class_name EffectBurn

func _init():
	numberOfHit = 7;
	delayPerHit = 0.7;
	damagePerHit = 7;

func apply_effect():
	super.apply_effect();
	var flip = false;
	for i in range(0, numberOfHit):
		# effect
		if parent == null:
			break;
		parent.takeDamage(damagePerHit);
		
		# effect visual
		parent.sprite.material.set_shader_parameter("flash_color", Color.RED);
		if (!flip):
			parent.sprite.material.set_shader_parameter("flash_value", 0.5);
			flip = true;
		else:
			parent.sprite.material.set_shader_parameter("flash_value", 0);
			flip = false;
		await get_tree().create_timer(delayPerHit).timeout;
		
	if (parent != null):
		parent.sprite.material.set_shader_parameter("flash_value", 0);
	queue_free();
