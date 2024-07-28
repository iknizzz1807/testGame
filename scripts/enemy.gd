extends CharacterBody2D

class_name Enemy

@export var SPEED : float = 10.0
@export var MAX_SPEED : float = 100;
@export var KNOCKBACK_STRENGTH : float = 1000;
@onready var sprite : Sprite2D = $Sprite2D;
@export var HP : int = 50; # Change on different types of enemies

var knockbackDirection : Vector2 = Vector2.ZERO;
var playerRef : Node2D;

func _ready():
	playerRef = get_tree().get_first_node_in_group("player");
	hit();

func _physics_process(delta):
	if playerRef != null:
		var playerDir = playerRef.position - position;
		velocity += playerDir.normalized() * SPEED;
	velocity += knockbackDirection;
	velocity = vector_clamp_length(velocity, 0, MAX_SPEED);
	knockbackDirection = Vector2.ZERO;
	move_and_collide(velocity * delta);
	#move_and_slide();

func vector_clamp_length(target: Vector2, min_length : float, max_length : float) -> Vector2:
	return target.normalized() * clamp(target.length(), min_length, max_length);

func knockback(dir: Vector2) -> void:
	knockbackDirection += dir * KNOCKBACK_STRENGTH;

func hit() -> void:
	flash();

func flash()->void:
	sprite.material.set_shader_parameter("flash_color", Color.WHITE);
	sprite.material.set_shader_parameter("flash_value", 1);
	await get_tree().create_timer(0.1).timeout; 
	sprite.material.set_shader_parameter("flash_color", Color.WHITE);
	sprite.material.set_shader_parameter("flash_value", 0);

func takeDamage(damage):
	if(HP <= 0):
		return;
	HP -= damage;
	if(HP <= 0):
		die();

func getSprite():
	return sprite;
	
func die():
	# Simulate the stats increase
	playerRef.EXP += 2;
	queue_free(); # Remove the enemy
	if(playerRef.EXP >= playerRef.maxEXP):
		playerRef.levelUp();
