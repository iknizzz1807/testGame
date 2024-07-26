extends Sprite2D

@export var recoilRot : float = 0;
@export var recoilPosX : float = 0;
@export var recoilPosY : float = 0;
@export var posOffset : Vector2 = Vector2.ZERO;

func _init():
	posOffset = position;
