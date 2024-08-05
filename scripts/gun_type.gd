extends Resource
class_name GunType;

@export_category("Setup")
@export var sprite: PackedScene;
@export_category("Properties")
@export var automatic : bool = false;
@export var isShotgun : bool = false;
@export var damage: float = 0;
@export var fireRate : float = 0.02;
@export var ammo : int = 30;
@export var reloadSpeed : float = 1;
@export var spreadAngle : float = 0;
@export_range(1, 999999) var spreadNumber : int = 0;
@export_range(1, 999999) var burstAmount : int = 0;
@export var burstDelay : float = 0;
@export_category("Modifications")
@export var effects : Array[Resource];
@export var sights : Array[GunMod];
@export var mags : Array[GunMod];
@export var muzzles : Array[GunMod];
@export var stocks : Array[GunMod];
@export var grips : Array[GunMod];
@export var fullAuto : GunMod;

func _get_configuration_warning():
	if (sprite != null):
		return "bro this doesn't have a sprite";
	pass
