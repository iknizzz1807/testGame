extends CharacterBody2D

class_name Player

signal shootEvent;
@export var speed = 400
@onready var gun : Gun = $Gun;

func _ready():
	pass

func get_input():
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown");
	velocity = input_direction * speed;

func _physics_process(_delta):
	get_input();
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
