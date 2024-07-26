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
@export var KNOCKBACK_STRENGTH : float = 200;
var knockbackStrength : Vector2 = Vector2.ZERO;
var HP : int = 5;

func _ready():
	pass

func get_input():
	var input_direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown");
	velocity = input_direction * speed;
	

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
		if (gun.type.automatic):
			canShoot = Input.is_action_pressed("shoot");
		else:
			canShoot = Input.is_action_just_pressed("shoot");
		if canShoot:
			shootEvent.emit();

func die() -> void:
	print("You died");
	get_tree().paused = true;

#func takeDamage(damage) ->void:
	#HP -= damage;
	#if(HP <= 0):
		#die();

func flash()->void:
	sprite.material.set_shader_parameter("flash_value", 1);
	await get_tree().create_timer(0.1).timeout;
	sprite.material.set_shader_parameter("flash_value", 0);

func _on_area_2d_body_entered(body):
	if (body != null) and (body is Enemy):
		#await get_tree().create_timer(0.2).timeout;
		flash();
		state = PlayerState.hit;
		animator.get("parameters/playback").travel("hit");
		knockback((position - body.position));
		await get_tree().create_timer(0.4).timeout;
		state = PlayerState.idle;
		#takeDamage(1);

func knockback(dir: Vector2) -> void:
	knockbackStrength += dir.normalized() * KNOCKBACK_STRENGTH;
