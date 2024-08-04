extends Resource
class_name GunMod

@export var sprite : PackedScene;
@export_range(-1, 1) var automatic : int = -1;
@export_range(-1, 1) var damageInc : float = 0;
@export_range(-1, 1) var fireRateInc : float = 0;
@export_range(-1, 1) var ammoInc : float = 0;
@export_range(-1, 1) var reloadSpeedInc : float = 0;
@export_range(-1, 1) var spreadAngleInc : float = 0;
@export_range(1, 999999) var spreadNumberNew : int = 0;
@export_range(1, 999999) var burstAmountNew : int = 0;
@export_range(-1, 1) var burstDelayInc : float = 0;
@export_range(-1, 1) var moveSpeedInc : float = 0;
