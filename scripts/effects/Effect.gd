extends Node2D
class_name Effect

@onready var parent : Enemy = get_parent();
var ran : bool = false;
var damagePerHit : float = 0;
var delayPerHit : float = 0;
var numberOfHit: int = 0;

func _enter_tree():
	if parent == null:
		parent = get_parent();

func _process(_delta):
	if (!ran):
		ran = true;
		apply_effect();

func apply_effect():
	pass
