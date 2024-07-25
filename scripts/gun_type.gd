extends Resource
class_name GunType;

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
@export_category("Setup")
@export var bulletPrefab : Resource;
@export var animator : Resource;
@export var sprite: Resource;
