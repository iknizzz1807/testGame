extends Effect
class_name Effect_Burn

@export var damagePerHit : float = 2;
@export var delayPerHit : float = 0.7;
@export var numberOfHit : int = 7;

func apply_effect():
	super.apply_effect();
	var flip = false;
	for i in range(0, numberOfHit):
		# effect
		if parent == null:
			break;
		parent.HP -= damagePerHit;
		
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
