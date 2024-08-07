extends Sprite2D
class_name GunVars

@export var recoilRot : float = 0;
@export var recoilPosX : float = 0;
@export var recoilPosY : float = 0;
@export var posOffset : Vector2 = Vector2.ZERO;
var casing : Marker2D = null;
var sight : Marker2D = null;
var mag : Marker2D = null;
var muzzle : Marker2D = null;
var stock : Marker2D = null;
var grip : Marker2D = null;
var fullAuto : Marker2D = null;

func _ready():
	if (has_node("Casing")):
		casing = $Casing;
	if (has_node("Sight")):
		sight = $Sight;
	if (has_node("Magazine")):
		mag = $Magazine;
	if (has_node("Muzzle")):
		muzzle = $Muzzle;
	if (has_node("Stock")):
		stock = $Stock;
	if (has_node("Grip")):
		grip = $Grip;
	if (has_node("FullAuto")):
		fullAuto = $FullAuto;
	posOffset = position;
