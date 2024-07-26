extends CharacterBody2D

class_name Player

enum PlayerState
{
	idle,
	hit,
	run
}
var state : PlayerState = PlayerState.idle;

signal shootEvent;
@export var speed = 400
@onready var gun : Gun = $Gun;
@onready var sprite : Sprite2D = $Sprite2D;
@onready var animator : AnimationTree = $AnimationTree;

func _ready():
	pass

func get_input():
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown");
	velocity = input_direction * speed;
	

func _physics_process(_delta):
	get_input();
	if (sign(velocity.length()) > 0):
		state = PlayerState.run;
	else:
		state = PlayerState.idle;
	if (velocity != Vector2.ZERO):
		sprite.flip_h = velocity.x < 0;
	move_and_collide(velocity);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var canShoot : bool = false;
	if (gun.type.automatic):
		canShoot = Input.is_action_pressed("shoot");
	else:
		canShoot = Input.is_action_just_pressed("shoot");
	if canShoot:
		shootEvent.emit();
