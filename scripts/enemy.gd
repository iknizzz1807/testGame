extends CharacterBody2D

class_name Enemy

enum EnemyState
{
	idle,
	running,
	hit
}

var state : EnemyState = EnemyState.idle;
@export var SPEED : float = 10.0
@export var MAX_SPEED : float = 100;
@export var KNOCKBACK_TIME : float = 0.2;
@export var KNOCKBACK_STRENGTH : float = 1000;
@export var KNOCKBACK_FRICTION : float = 100;
@onready var sprite : Sprite2D = $Sprite2D;
@onready var knife : Sprite2D = $Sprite2D/Knife;
@export var HP : int = 50; # Change on different types of enemies
var tmpTimer : SceneTreeTimer;
var knockbackTimer : float = 0;


var knockbackDirection : Vector2 = Vector2.ZERO;
var playerRef : Node2D;

func _ready():
	playerRef = get_tree().get_first_node_in_group("player");

func _physics_process(delta):
	match state:
		EnemyState.hit:
			velocity *= 0.7;
			if velocity.x < 0:
				sprite.scale.x = abs(sprite.scale.x) * 1;
			else:
				sprite.scale.x = abs(sprite.scale.x) * -1;
			var collider = move_and_collide(velocity * delta);
			if (collider != null):
				velocity = velocity.slide(collider.get_normal());
			if (velocity.length_squared() > 0):
				knockbackTimer -= delta;
			if (knockbackTimer <= 0):
				state = EnemyState.idle;
		_:
			if (playerRef != null):
				var playerDir = playerRef.position - position;
				velocity += playerDir.normalized() * SPEED;
			if (velocity.length_squared() > 0):
				state = EnemyState.running;
			else:
				state = EnemyState.idle;
			velocity = velocity.limit_length(MAX_SPEED);
			if velocity.x > 0:
				sprite.scale.x = abs(sprite.scale.x) * 1;
			else:
				sprite.scale.x = abs(sprite.scale.x) * -1;
			move_and_collide(velocity * delta);

func vector_clamp_length(target: Vector2, min_length : float, max_length : float) -> Vector2:
	return target.normalized() * clamp(target.length(), min_length, max_length);

func flash()->void:
	sprite.material.set_shader_parameter("flash_color", Color.WHITE);
	sprite.material.set_shader_parameter("flash_value", 1);
	await get_tree().create_timer(0.1).timeout; 
	sprite.material.set_shader_parameter("flash_color", Color.WHITE);
	sprite.material.set_shader_parameter("flash_value", 0);

func hit(damage: float, knockbackDir: Vector2):
	if(HP <= 0):
		return;
	HP -= damage;
	flash();
	state = EnemyState.hit;
	Global.stop_time(0.05, 0.005);
	knockbackTimer = KNOCKBACK_TIME;
	#knockbackDirection += knockbackDir.normalized() * KNOCKBACK_STRENGTH;
	velocity = knockbackDir.normalized() * KNOCKBACK_STRENGTH;
	#knockbackDirection = Vector2.ZERO;
	if(HP <= 0):
		die();

func die():
	# Simulate the stats increase
	playerRef.EXP += 2;
	queue_free(); # Remove the enemy
	if(playerRef.EXP >= playerRef.maxEXP):
		playerRef.levelUp();
