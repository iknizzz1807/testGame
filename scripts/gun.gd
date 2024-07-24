extends Node2D

class_name Gun;

const bulletPrefab = preload("res://prefabs/bullet.tscn");

enum GUNS {AK47 = 3, PISTOL = 1, M4 = 2};
@export var GUN_TYPE: GUNS = GUNS.AK47; #
@onready var sprite : Sprite2D = $AK47;

func _ready():
	pass

func get_damage() -> int:
	match GUN_TYPE:
		GUNS.AK47:
			return GUNS.AK47;
		GUNS.PISTOL:
			return GUNS.PISTOL;
		GUNS.M4:
			return GUNS.M4;
	return 0;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotation = (get_global_mouse_position() - global_position).angle();
	if (abs(rotation_degrees) <= 90):
		sprite.scale.y = abs(sprite.scale.y) * 1;
	else:
		sprite.scale.y = abs(sprite.scale.y) * -1;
	pass
	
func bulletOut():
	var bullet = bulletPrefab.instantiate();
	get_parent().get_parent().add_child(bullet);
	bullet.position = get_parent().position;
	bullet.look_at(get_global_mouse_position());
	bullet.direction = get_global_mouse_position() - bullet.position;
	bullet.damage = get_damage();

func _on_player_shoot():
	bulletOut();
	pass

func gun_init():
	GUN_TYPE = GUNS.PISTOL; # Replace this
