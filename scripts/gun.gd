extends Node2D
class_name Gun;

var bulletPrefab = preload("res://prefabs/bullet.tscn");
var casingPrefab = preload("res://prefabs/casing.tscn");

@export var gunType : GunType;

@export var recoilRot: float = 0;
@export var recoilPosX: float = 0;
@export var recoilPosY: float = 0;

var spreadMult : float = 0;
var bulletSpawnPoint : Node2D;
var sprite : Sprite2D;
var spriteAnimator : AnimationTree;
var recoilAnimator : AnimationPlayer;
var parent : Player;
var aimDir : Vector2;

var ammoCounter : int;
var fireRateCounter: float = 0;
var reloading : bool = false;
var casingPos : Marker2D;
var reloadTimer : SceneTreeTimer;

func _ready():
	if (get_parent().debugGun):
		await get_parent().ready;
		gunInit();
		gunModTier(10);
	if (get_parent() is Player):
		parent = get_parent();
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
	ammoCounter = gunType.ammo;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = aimDir.angle();
	var sprPosOffset = sprite.posOffset;
	if (abs(rotation_degrees) <= 90):
		sprite.scale.y = abs(sprite.scale.y) * 1;
		sprPosOffset.y *= 1;
	else:
		sprite.scale.y = abs(sprite.scale.y) * -1;
		sprPosOffset.y *= -1;
	sprite.position = sprPosOffset + Vector2(sprite.recoilPosX, sprite.recoilPosY * sign(sprite.scale.y));
	sprite.rotation_degrees =  sprite.recoilRot * sign(sprite.scale.y);
	if (fireRateCounter > 0):
		fireRateCounter -= delta;
	
	spriteAnimator.set("parameters/conditions/reloading", false);
	spriteAnimator.set("parameters/conditions/shooting", false);
	
	pass

func swapGun(level: int) -> void:
	var nextGun = GunGameManager.GetGun(level);
	if nextGun == null:
		return;
	for child in get_children():
		child.queue_free();
	gunType = nextGun.duplicate();
	gunInit();
	gunModTier(level);
	ammoCounter = gunType.ammo;
	pass

func gunModTier(level : int) -> void:
	var gunVars = sprite as GunVars;
	casingPos = gunVars.casing;
	var player : Player = get_parent();
	
	if (level / GunGameManager.guns.size() >= 1 || player.debugGun):
		if (randi_range(0, 1) == 0 && gunType.fullAuto != null):
			var gunModFullAuto = gunType.fullAuto as GunMod;
			addGunMod(gunModFullAuto, gunVars.fullAuto);
		
		if (!gunType.mags.is_empty()):
			var gunModMag = gunType.mags.pick_random() as GunMod;
			addGunMod(gunModMag, gunVars.mag);
	else:
		if (!gunType.mags.is_empty()):
			var gunModMag = gunType.mags[0] as GunMod;
			addGunMod(gunModMag, gunVars.mag);
	
	if (level / GunGameManager.guns.size() >= 2 || player.debugGun):
		if (!gunType.sights.is_empty()):
			var gunModSight = gunType.sights.pick_random() as GunMod;
			addGunMod(gunModSight, gunVars.sight);
	else:
		if (!gunType.sights.is_empty()):
			var gunModSight = gunType.sights[0] as GunMod;
			addGunMod(gunModSight, gunVars.sight);
	
	if (level / GunGameManager.guns.size() >= 3 || player.debugGun):
		if (!gunType.muzzles.is_empty()):
			var gunModMuzzle = gunType.muzzles.pick_random() as GunMod;
			addGunMod(gunModMuzzle, gunVars.muzzle);
	else:
		if (!gunType.muzzles.is_empty()):
			var gunModMuzzle = gunType.muzzles[0] as GunMod;
			addGunMod(gunModMuzzle, gunVars.muzzle);
	
	if (level / GunGameManager.guns.size() >= 4 || player.debugGun):
		if (!gunType.stocks.is_empty()):
			var gunModStock = gunType.stocks.pick_random() as GunMod;
			addGunMod(gunModStock, gunVars.stock);
	else:
		if (!gunType.stocks.is_empty()):
			var gunModStock = gunType.stocks[0] as GunMod;
			addGunMod(gunModStock, gunVars.stock);
	
	
	if (level / GunGameManager.guns.size() >= 5 || player.debugGun):
		if (!gunType.grips.is_empty()):
			var gunModGrip = gunType.grips.pick_random() as GunMod;
			addGunMod(gunModGrip, gunVars.grip);
	

func addGunMod(mod : GunMod, marker : Marker2D) -> void:
	if (mod.sprite != null):
		marker.add_child(mod.sprite.instantiate());
	if (mod.automatic != -1):
		gunType.automatic = mod.automatic;
	gunType.ammo *= 1 + mod.ammoInc;
	ammoCounter = gunType.ammo;
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
		try_play_animation(spriteAnimator, "reload");
		await get_tree().create_timer(gunType.reloadSpeed).timeout;
		ammoCounter = gunType.ammo;
		fireRateCounter = 0;
		reloading = false;

func _on_player_shoot_event():
	if (reloading && gunType.isShotgun && ammoCounter > 0):
		reloading = false;
	if (fireRateCounter > 0 || reloading):
		return;
	owner
	if (ammoCounter > 0):
		Global.shake_camera(aimDir);
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
		try_play_animation(spriteAnimator, "shoot");
		# gun
		ammoCounter -= 1;
		parent.knockback(-aimDir, gunType.knockbackStrength, gunType.knockbackFriction);
		await get_tree().create_timer(gunType.burstDelay).timeout;

func spawnCasing() -> void:
	if (casingPos != null):
		var casing : Sprite2D = casingPrefab.instantiate();
		casing.texture = gunType.casing;
		casing.global_position = casingPos.global_position;
		casing.scale.x *= sign(sprite.scale.y);
		get_tree().root.add_child(casing);

func spawnBullet() -> void:
	for i in range(0, max(1, gunType.spreadNumber)):
		var spread = randf_range(-gunType.spreadAngle, gunType.spreadAngle);
		if (gunType.spreadNumber <= 1):
			spread *= max(0.4, spreadMult);
		# Setup
		var bullet = bulletPrefab.instantiate() as Bullet;
		get_tree().root.add_child(bullet);
		
		bullet.global_position = bulletSpawnPoint.global_position;
		
		bullet.rotation = aimDir.angle();
		bullet.rotation_degrees += spread + sprite.rotation_degrees;
		bullet.direction = Vector2.from_angle(bullet.rotation);
		bullet.damage = gunType.damage;
		bullet.fireRate = gunType.fireRate;
		bullet.effects = gunType.effects;

func try_play_animation(animator : AnimationTree, animation_name : String):
	if (animator.has_animation(animation_name)):
		#animator.get("parameters/playback").stop();
		animator.get("parameters/playback").start(animation_name, true);
	pass
