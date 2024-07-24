extends Node2D
class_name Gun;

const bulletPrefab = preload("res://prefabs/bullet.tscn");

#enum GUNS {AK47 = 3, PISTOL = 1, M4 = 2};
@export var type : GunType;

@export var recoilRot: float = 0;
@export var recoilPosX: float = 0;
@export var recoilPosY: float = 0;

@onready var bulletSpawnPoint : Node2D = $AK47/BulletSpawnPoint;
@onready var sprite : Sprite2D = $AK47;
@onready var animation : AnimationPlayer;

var fireRateCounter: float = 0;

func _ready():
	sprite.texture = type.sprite;
	animation = type.animator.instantiate();
	add_child(animation);
	pass
'''
func get_damage() -> int:
	match GUN_TYPE:
		GUNS.AK47:
			return GUNS.AK47;
		GUNS.PISTOL:
			return GUNS.PISTOL;
		GUNS.M4:
			return GUNS.M4;
	return 0;
'''

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = (get_global_mouse_position() - global_position).angle();
	if (abs(rotation_degrees) <= 90):
		sprite.scale.y = abs(sprite.scale.y) * 1;
	else:
		sprite.scale.y = abs(sprite.scale.y) * -1;
	sprite.position = Vector2(recoilPosX, recoilPosY);
	sprite.rotation_degrees = rotation + recoilRot * sign(sprite.scale.y);
	print(fireRateCounter);
	if (fireRateCounter > 0):
		fireRateCounter -= delta;
	pass
	
func bulletOut() -> void:
	var bullet = bulletPrefab.instantiate();
	get_tree().root.add_child(bullet);
	bullet.global_position = bulletSpawnPoint.global_position;
	bullet.look_at(get_global_mouse_position());
	bullet.direction = get_global_mouse_position() - bullet.position;
	bullet.damage = type.damage;

func _on_player_shoot() -> void:
	if (fireRateCounter > 0):
		return;
	bulletOut();
	fireRateCounter = type.fireRate;
	animation.stop();
	animation.play("recoil");
	pass

func gun_init():
	pass
	#GUN_TYPE = GUNS.PISTOL; # Replace this
