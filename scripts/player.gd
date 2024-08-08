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


@export_subgroup("Debug")
@export var debugGun = false;
@export_subgroup("Vars")
@export var speed : float = 400;
@export var KNOCKBACK_STRENGTH : float = 800;
@export var MOVE_FRICTION : float = 30;
@export var HP : int = 5;
@export var maxHP : int = 5;
@export var power : int = 0;

var canShoot : bool = false;
var knockbackStrength : Vector2 = Vector2.ZERO;
var speedInc : float = 0;
var EXP : int = 0;
var level : int = 1;
var maxEXP : int = 10;
var knockbackFriction : float = MOVE_FRICTION;

@onready var gun : Gun = $Gun;
@onready var sprite : Sprite2D = $Sprite2D;
@onready var animator : AnimationTree = $AnimationTree;
@onready var statCanvas : CanvasLayer = $"../statCanvas";

func _ready():
	GunGameManager.debugGun = debugGun;
	gun.swapGun(0);
	pass

# Process Input
func _process(_delta):
	gun.aimDir = get_global_mouse_position() - global_position;
	if (gun.gunType.automatic):
		canShoot = Input.is_action_pressed("shoot");
	else:
		canShoot = Input.is_action_just_pressed("shoot");
	if (Input.is_action_just_pressed("reload")):
		gun.reload();

func _physics_process(_delta):
	var input_direction = \
		Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown").normalized();
	if (state != PlayerState.hit):
		if (velocity.length() > 0):
			state = PlayerState.run;
		else:
			state = PlayerState.idle;
		if (gun.aimDir != Vector2.ZERO):
			sprite.flip_h = gun.aimDir.x < 0;
		velocity += input_direction * speed * (1 + speedInc);
	velocity = velocity.move_toward(Vector2.ZERO, MOVE_FRICTION + 20);
	velocity = velocity.limit_length(speed);
	move_and_collide((velocity + knockbackStrength) * _delta);
	knockbackStrength = knockbackStrength.move_toward(Vector2.ZERO, knockbackFriction);
	
	
	if canShoot:
		gun.spreadMult = velocity.length() / speed;
		shootEvent.emit();


func die() -> void:
	statCanvas.get_child(1).text = str(level) + "\n" + "0" + "/" + str(maxHP) + "\n" + str(power) + "\n" + str(EXP) + "/" + str(maxEXP);
	get_tree().paused = true;
	Engine.time_scale = 0;
	print("You died");

func takeDamage(damage) ->void:
	#print("You took damage");
	HP -= damage;
	if(HP <= 0):
		die();

func flash()->void:
	sprite.material.set_shader_parameter("flash_value", 1);
	await get_tree().create_timer(0.1).timeout;
	sprite.material.set_shader_parameter("flash_value", 0);


func knockback(dir: Vector2, magnitude : float, friction : float = MOVE_FRICTION) -> void:
	knockbackStrength += dir.normalized() * magnitude;
	knockbackFriction = friction;
	
func levelUp() -> void:
	level += 1;
	EXP = EXP - maxEXP;
	gun.swapGun(level - 1);
	maxEXP += 5;
	maxHP += 2;
	power += 1;

func _on_area_2d_body_entered(body):
	if (body != null) and (body is Enemy) and (state != PlayerState.hit):
		flash();
		state = PlayerState.hit;
		animator.get("parameters/playback").travel("hit");
		knockback((position - body.position), KNOCKBACK_STRENGTH);
		takeDamage(1); # Change this
		await get_tree().create_timer(0.4).timeout;
		state = PlayerState.idle;
