extends Sprite2D
class_name GunVars

@export var recoilRot : float = 0;
@export var recoilPosX : float = 0;
@export var recoilPosY : float = 0;
@export var posOffset : Vector2 = Vector2.ZERO;
var sight : Marker2D;
var muzzle : Marker2D;
var fullAuto : Marker2D;
var mag : Marker2D;

func _ready():
	sight = $Sight;
	muzzle = $Muzzle;
	fullAuto = $FullAuto;
	mag = $Magazine;
	posOffset = position;
