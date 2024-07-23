extends RigidBody2D

const bulletPrefab = preload("res://prefabs/bullet.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("shoot"):
		var bullet = bulletPrefab.instantiate();
		
		get_parent().add_child(bullet);
		bullet.position = position;
		bullet.look_at(get_global_mouse_position());
		bullet.get_child(0).direction = get_global_mouse_position() - bullet.position;
			
	pass
