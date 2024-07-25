extends CharacterBody2D
class_name Enemy

@export var SPEED : float = 100.0
@export var KNOCKBACK_STRENGTH : float = 800;
@onready var sprite : Sprite2D = $Sprite2D;
@export var HP : int = 100; # Change on different types of enemies

var knockbackStrength : Vector2 = Vector2.ZERO;
var playerRef : Node2D;

func _ready():
	playerRef = get_tree().get_first_node_in_group("player")
	hit();

func _physics_process(delta):
	if playerRef != null:
		var playerDir = playerRef.position - position;
		velocity = playerDir.normalized() * SPEED;
	velocity += knockbackStrength;
	knockbackStrength = Vector2.ZERO;
	move_and_collide(velocity * delta)


func knockback(dir: Vector2) -> void:
	knockbackStrength += dir.normalized() * KNOCKBACK_STRENGTH;

func hit() -> void:
	flash();

func flash()->void:
	sprite.material.set_shader_parameter("flash_value", 1);
	await get_tree().create_timer(0.1).timeout;
	sprite.material.set_shader_parameter("flash_value", 0);

func takeDamage(damage):
	HP -= damage;
	if(HP <= 0):
		print(name + " died");
		queue_free(); # Remove the enemy
