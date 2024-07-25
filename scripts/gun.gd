extends Node2D
class_name Gun;

#enum GUNS {AK47 = 3, PISTOL = 1, M4 = 2};
@export var type : GunType;

@export var recoilRot: float = 0;
@export var recoilPosX: float = 0;
@export var recoilPosY: float = 0;

@onready var bulletSpawnPoint : Node2D = $AK47/BulletSpawnPoint;
@onready var sprite : Sprite2D = $AK47;
@onready var animation : AnimationPlayer = $AnimationPlayer;

var ammoCounter : int;
var fireRateCounter: float = 0;
var reloading : bool = false;


func _ready():
	ammoCounter = type.ammo;
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = (get_global_mouse_position() - global_position).angle();
	if (abs(rotation_degrees) <= 90):
		sprite.scale.y = abs(sprite.scale.y) * 1;
	else:
		sprite.scale.y = abs(sprite.scale.y) * -1;
	sprite.position = Vector2(recoilPosX, recoilPosY);
	sprite.rotation_degrees = rotation + recoilRot * sign(sprite.scale.y);
	if (fireRateCounter > 0):
		fireRateCounter -= delta;
	pass
	
func bulletOut() -> void:
	# clamp: max(1, min(type.burstAmount, ammoCounter):
	for i in range(0, clamp(type.burstAmount, 1, ammoCounter)):
		if (is_instance_valid(self) == null): return;
		spawnBullet();
		animation.stop(true);
		animation.play("recoil");
		# gun
		ammoCounter -= 1;
		await get_tree().create_timer(type.burstDelay).timeout;

func spawnBullet() -> void:
	for i in range(0, max(1, type.spreadNumber)):
		var spread = randf_range(-type.spreadAngle, type.spreadAngle);
		# Setup
		var bullet = type.bulletPrefab.instantiate() as Bullet;
		get_tree().root.add_child(bullet);
		
		bullet.global_position = bulletSpawnPoint.global_position;
		
		bullet.look_at(get_global_mouse_position());
		bullet.rotation_degrees += spread + sprite.rotation_degrees;
		bullet.direction = Vector2.from_angle(bullet.rotation);
		bullet.damage = type.damage;
		bullet.fireRate = type.fireRate;

func _on_player_shoot_event():
	if (fireRateCounter > 0 || reloading):
		return;
	bulletOut();
	fireRateCounter = type.fireRate + type.burstAmount * type.burstDelay;
	if (ammoCounter <= 0):
		reload();

func reload() -> void:
	reloading = true;
	await get_tree().create_timer(type.reloadSpeed).timeout;
	ammoCounter = type.ammo;
	fireRateCounter = 0;
	reloading = false;
