extends Node2D
class_name Gun;

var bulletPrefab = preload("res://prefabs/bullet.tscn");

@export var gunType : GunType;

@export var recoilRot: float = 0;
@export var recoilPosX: float = 0;
@export var recoilPosY: float = 0;

var spreadMult : float = 0;
var bulletSpawnPoint : Node2D;
var sprite : Sprite2D;
var spriteAnimator : AnimationTree;
var recoilAnimator : AnimationPlayer;

var ammoCounter : int;
var fireRateCounter: float = 0;
var reloading : bool = false;
var casingPos : Marker2D;
var reloadTimer : SceneTreeTimer;

func _ready():
	if (get_parent().debugGun):
		await get_parent().ready;
		gunInit();
	pass

func gunInit() -> void:
	sprite = gunType.sprite.instantiate();
	add_child(sprite);
	
	bulletSpawnPoint = sprite.get_node(sprite.get_meta("BulletSpawnPoint"));
	assert(bulletSpawnPoint != null, name + " has no bulletSpawnPoint wtf");
	
	spriteAnimator = sprite.get_node(sprite.get_meta("Animator"));
	assert(spriteAnimator != null, name + " has no animator wtf");
	
	recoilAnimator = sprite.get_node(sprite.get_meta("RecoilAnimator"));
	assert(recoilAnimator != null, name + " has no recoil animator wtf");
	
	
	var gunVars = sprite as GunVars;
	casingPos = gunVars.casing;
	
	if (randi_range(0, 1) == 0 && gunType.fullAuto != null):
		var gunModFullAuto = gunType.fullAuto as GunMod;
		addGunMod(gunModFullAuto, gunVars.fullAuto);
		pass
	
	if (!gunType.mags.is_empty()):
		var gunModMag = gunType.mags.pick_random() as GunMod;
		addGunMod(gunModMag, gunVars.mag);
	
	if (!gunType.sights.is_empty()):
		var gunModSight = gunType.sights.pick_random() as GunMod;
		addGunMod(gunModSight, gunVars.sight);
	
	if (!gunType.muzzles.is_empty()):
		var gunModMuzzle = gunType.muzzles.pick_random() as GunMod;
		addGunMod(gunModMuzzle, gunVars.muzzle);
		
	if (!gunType.grips.is_empty()):
		var gunModGrip = gunType.grips.pick_random() as GunMod;
		addGunMod(gunModGrip, gunVars.grip);
	
	if (!gunType.stocks.is_empty()):
		var gunModStock = gunType.stocks.pick_random() as GunMod;
		addGunMod(gunModStock, gunVars.stock);
	
	ammoCounter = gunType.ammo;
	
	

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
	sprite.position = sprPosOffset + Vector2(sprite.recoilPosX, sprite.recoilPosY * sign(sprite.scale.y));
	sprite.rotation_degrees = rotation + sprite.recoilRot * sign(sprite.scale.y);
	if (fireRateCounter > 0):
		fireRateCounter -= delta;
	
	spriteAnimator.set("parameters/conditions/reloading", false);
	spriteAnimator.set("parameters/conditions/shooting", false);
	
	pass

func addGunMod(mod : GunMod, marker : Marker2D) -> void:
	if (mod.sprite != null):
		marker.add_child(mod.sprite.instantiate());
	if (mod.automatic != -1):
		gunType.automatic = mod.automatic;
	gunType.ammo *= 1 + mod.ammoInc;
	gunType.damage *= 1 + mod.damageInc;
	gunType.fireRate *= 1 + mod.fireRateInc;
	gunType.reloadSpeed *= 1 + mod.reloadSpeedInc;
	gunType.spreadAngle *= 1 + mod.spreadAngleInc;
	if (mod.spreadNumberNew != 0):
		gunType.spreadNumber = mod.spreadNumberNew;
	if (mod.burstAmountNew != 0):
		gunType.burstAmount = mod.burstAmountNew;
	gunType.burstDelay = mod.burstDelayInc;
	var player = get_owner() as Player;
	player.speedInc = mod.moveSpeedInc;
	pass

func swapGun(level: int) -> void:
	var nextGun = GunGameManager.GetGun(level);
	if nextGun == null:
		return;
	for child in get_children():
		child.queue_free();
	gunType = nextGun;
	gunInit();
	pass


func reload() -> void:
	if (reloading || reloadTimer != null): return;
	if (gunType.isShotgun):
		reloading = true;
		while (ammoCounter < gunType.ammo && reloading):
			# spriteAnimator.set("parameters/conditions/reloading", true);
			# try_travel_animation(spriteAnimator, "reload");
			reloadTimer = get_tree().create_timer(gunType.reloadSpeed);
			await reloadTimer.timeout;
			if (ammoCounter < gunType.ammo && reloading):
				ammoCounter += 1;
		reloadTimer = null;
		reloading = false;
	else:
		reloading = true;
		spriteAnimator.set("parameters/conditions/reloading", true);
		try_travel_animation(spriteAnimator, "reload");
		await get_tree().create_timer(gunType.reloadSpeed).timeout;
		ammoCounter = gunType.ammo;
		fireRateCounter = 0;
		reloading = false;

func _on_player_shoot_event():
	if (reloading && gunType.isShotgun && ammoCounter > 0):
		reloading = false;
	if (fireRateCounter > 0 || reloading):
		return;
	if (ammoCounter > 0):
		get_viewport().get_camera_2d().apply_shake();
		bulletOut();
		fireRateCounter = gunType.fireRate + gunType.burstAmount * gunType.burstDelay;
	if (ammoCounter <= 0):
		reload();

func bulletOut() -> void:
	# clamp: max(1, min(gunType.burstAmount, ammoCounter):
	for i in range(0, clamp(gunType.burstAmount, 1, ammoCounter)):
		if (is_instance_valid(self) == null): return;
		spawnBullet();
		recoilAnimator.stop(true);
		recoilAnimator.play("recoil");
		spriteAnimator.set("parameters/conditions/shooting", true);
		try_travel_animation(spriteAnimator, "shoot");
		# gun
		ammoCounter -= 1;
		if (casingPos != null):
			var casing = gunType.casing.instantiate();
			casing.global_position = casingPos.global_position;
			casing.scale.x *= sign(sprite.scale.y);
			get_tree().root.add_child(casing);
		await get_tree().create_timer(gunType.burstDelay).timeout;

func spawnBullet() -> void:
	for i in range(0, max(1, gunType.spreadNumber)):
		var spread = randf_range(-gunType.spreadAngle, gunType.spreadAngle);
		if (gunType.spreadNumber <= 1):
			spread *= max(0.4, spreadMult);
		# Setup
		var bullet = bulletPrefab.instantiate() as Bullet;
		get_tree().root.add_child(bullet);
		
		bullet.global_position = bulletSpawnPoint.global_position;
		
		bullet.look_at(get_global_mouse_position());
		bullet.rotation_degrees += spread + sprite.rotation_degrees;
		bullet.direction = Vector2.from_angle(bullet.rotation);
		bullet.damage = gunType.damage;
		bullet.fireRate = gunType.fireRate;
		bullet.effects = gunType.effects;

func try_travel_animation(animator : AnimationTree, animation_name : String):
	if (animator.has_animation(animation_name)):
		animator.get("parameters/playback").travel(animation_name);
	pass
