extends CharacterBody2D
const bulletPrefab = preload("res://prefabs/bullet.tscn");
signal shoot;
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

@export var speed = 400

func get_input():
	look_at(get_global_mouse_position());
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown");
	velocity = input_direction * speed;

func _physics_process(_delta):
	get_input();
	move_and_slide();




func bulletOut():
	var bullet = bulletPrefab.instantiate();
	get_parent().add_child(bullet);
	bullet.position = position;
	bullet.look_at(get_global_mouse_position());
	shoot.emit();
	bullet.direction = get_global_mouse_position() - bullet.position;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("shoot"):
		bulletOut();
