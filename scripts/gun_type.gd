extends Resource
class_name GunType;

@export_category("Setup")
@export var sprite: Resource;
@export_category("Properties")
@export var automatic : bool = false;
@export var damage: float = 0;
@export var fireRate : float = 0.02;
@export var ammo : int = 30;
@export var reloadSpeed : float = 1;
@export var spreadAngle : float = 0;
@export_range(1, 999999) var spreadNumber : int = 0;
@export_range(1, 999999) var burstAmount : int = 0;
@export var burstDelay : float = 0;

func _init():
	# assert(sprite != null, resource_name + " doesn't has a sprite");
	# assert(bulletPrefab != null, resource_name + " doesn't has a bullet");
	pass

func _get_configuration_warning():
	if (sprite != null):
		return "bro this doesn't have a sprite";
	pass
