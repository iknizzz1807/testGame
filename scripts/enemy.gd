extends CharacterBody2D

@export var SPEED : float = 300.0

@onready var sprite : Sprite2D = $Sprite2D;

var playerRef : Node2D;

func _ready():
	playerRef = get_tree().get_first_node_in_group("player")
	hit();

func _physics_process(delta):
	if playerRef != null:
		var playerDir = playerRef.position - position;
		velocity = playerDir.normalized() * SPEED * delta;
	
	
	move_and_collide(velocity)


func hit() -> void:
	flash();

func flash()->void:
	
	sprite.material.set_shader_parameter("flash_value", 1);
	await get_tree().create_timer(0.1).timeout;
	sprite.material.set_shader_parameter("flash_value", 0);
