extends CharacterBody2D

class_name Player

signal shoot;
@export var speed = 400

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
	if Input.is_action_just_pressed("shoot"):
		shoot.emit();
