extends Node2D

var guns : Array[GunType] = [
	preload("res://resources/guns/glock/glock.tres"),
	preload("res://resources/guns/beretta/beretta.tres"),
	preload("res://resources/guns/deserteagle/deserteagle.tres"),
	preload("res://resources/guns/m3/m3.tres"),
	preload("res://resources/guns/xm1014/xm1014.tres"),
	preload("res://resources/guns/mp9/mp9.tres"),
	preload("res://resources/guns/m4a1/m4a1.tres"),
	preload("res://resources/guns/ak47/ak47.tres"),
];

var debugGun = false;

func GetGun(level : int) -> GunType:
	if debugGun:
		return null;
	if (level != 0 && level % (guns.size()) == 0):
		guns.shuffle();
	return guns[clamp(level % (guns.size()), 0, guns.size() - 1)];
