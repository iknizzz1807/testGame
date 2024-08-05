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
@export var speed = 400
@onready var gun : Gun = $Gun;
@onready var sprite : Sprite2D = $Sprite2D;
@onready var animator : AnimationTree = $AnimationTree;
@onready var statCanvas : CanvasLayer = $"../statCanvas";
@export var KNOCKBACK_STRENGTH : float = 200;
var knockbackStrength : Vector2 = Vector2.ZERO;
var speedInc : float = 0;
@export var HP : int = 5;
@export var maxHP : int = 5;
@export var power : int = 0;
var EXP : int = 0;
var level : int = 1;
var maxEXP : int = 10;

func _ready():
	GunGameManager.debugGun = debugGun;
	gun.swapGun(0);
	pass

func get_input():
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown");
	velocity = input_direction * speed * (1 + speedInc);

func _physics_process(_delta):
	if (state != PlayerState.hit):
		if (sign(velocity.length()) > 0):
			state = PlayerState.run;
		else:
			state = PlayerState.idle;
		if (velocity != Vector2.ZERO):
			sprite.flip_h = velocity.x < 0;
		get_input();
	velocity += knockbackStrength;
	knockbackStrength = Vector2.ZERO;
	move_and_collide(velocity * _delta);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if (state != PlayerState.hit):
		var canShoot : bool = false;
		if (gun.gunType.automatic):
			canShoot = Input.is_action_pressed("shoot");
		else:
			canShoot = Input.is_action_just_pressed("shoot");
		if (Input.is_action_just_pressed("reload")):
			gun.reload();
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

func _on_area_2d_body_entered(body):
	if (body != null) and (body is Enemy):
		flash();
		state = PlayerState.hit;
		animator.get("parameters/playback").travel("hit");
		knockback((position - body.position));
		takeDamage(1); # Change this
		await get_tree().create_timer(0.4).timeout;
		state = PlayerState.idle;

func knockback(dir: Vector2) -> void:
	knockbackStrength += dir.normalized() * KNOCKBACK_STRENGTH;
	
func levelUp() -> void:
	level += 1;
	EXP = EXP - maxEXP;
	gun.swapGun(level - 1);
	maxEXP += 5;
	maxHP += 2;
	power += 1;
