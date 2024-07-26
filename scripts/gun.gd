extends Node2D
class_name Gun;

var bulletPrefab = preload("res://prefabs/bullet.tscn");

@export var type : GunType;

@export var recoilRot: float = 0;
@export var recoilPosX: float = 0;
@export var recoilPosY: float = 0;

var bulletSpawnPoint : Node2D;
var sprite : Sprite2D;
var spriteAnimator : AnimationTree;
var recoilAnimator : AnimationPlayer;

var ammoCounter : int;
var fireRateCounter: float = 0;
var reloading : bool = false;


func _ready():
	sprite = type.sprite.instantiate();
	add_child(sprite);
	
	bulletSpawnPoint = sprite.get_node(sprite.get_meta("BulletSpawnPoint"));
	assert(bulletSpawnPoint != null, name + " has no bulletSpawnPoint wtf");
	
	spriteAnimator = sprite.get_node(sprite.get_meta("Animator"));
	assert(spriteAnimator != null, name + " has no animator wtf");
	
	recoilAnimator = sprite.get_node(sprite.get_meta("RecoilAnimator"));
	assert(recoilAnimator != null, name + " has no recoil animator wtf");
	
	ammoCounter = type.ammo;
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	
	rotation = (get_global_mouse_position() - global_position).angle();
	var sprPosOffset = sprite.posOffset;
	if (abs(rotation_degrees) <= 90):
		sprite.scale.y = abs(sprite.scale.y) * 1;
		sprPosOffset.y *= 1;
	else:
		sprite.scale.y = abs(sprite.scale.y) * -1;
		sprPosOffset.y *= -1;
	sprite.position = sprPosOffset + Vector2(sprite.recoilPosX, sprite.recoilPosY);
	sprite.rotation_degrees = rotation + sprite.recoilRot * sign(sprite.scale.y);
	if (fireRateCounter > 0):
		fireRateCounter -= delta;
	
	spriteAnimator.set("parameters/conditions/reloading", false);
	spriteAnimator.set("parameters/conditions/shooting", false);
	
	pass

func bulletOut() -> void:
	# clamp: max(1, min(type.burstAmount, ammoCounter):
	for i in range(0, clamp(type.burstAmount, 1, ammoCounter)):
		if (is_instance_valid(self) == null): return;
		spawnBullet();
		recoilAnimator.stop(true);
		recoilAnimator.play("recoil");
		spriteAnimator.set("parameters/conditions/shooting", true);
		try_travel_animation(spriteAnimator, "shoot");
		# gun
		ammoCounter -= 1;
		await get_tree().create_timer(type.burstDelay).timeout;

func spawnBullet() -> void:
	for i in range(0, max(1, type.spreadNumber)):
		var spread = randf_range(-type.spreadAngle, type.spreadAngle);
		# Setup
		var bullet = bulletPrefab.instantiate() as Bullet;
		get_tree().root.add_child(bullet);
		
		bullet.global_position = bulletSpawnPoint.global_position;
		
		bullet.look_at(get_global_mouse_position());
		bullet.rotation_degrees += spread + sprite.rotation_degrees;
		bullet.direction = Vector2.from_angle(bullet.rotation);
		bullet.damage = type.damage;
		bullet.fireRate = type.fireRate;
		bullet.effects = type.effects;

func _on_player_shoot_event():
	if (fireRateCounter > 0 || reloading):
		return;
	get_viewport().get_camera_2d().apply_shake();
	bulletOut();
	fireRateCounter = type.fireRate + type.burstAmount * type.burstDelay;
	if (ammoCounter <= 0):
		reload();

func reload() -> void:
	reloading = true;
	spriteAnimator.set("parameters/conditions/reloading", true);
	try_travel_animation(spriteAnimator, "reload");
	await get_tree().create_timer(type.reloadSpeed).timeout;
	ammoCounter = type.ammo;
	fireRateCounter = 0;
	reloading = false;


func try_travel_animation(animator : AnimationTree, animation_name : String):
	if (animator.has_animation(animation_name)):
		animator.get("parameters/playback").travel(animation_name);
	pass
