extends CharacterBody2D

@export var SPEED : float = 300.0

var playerRef : Node2D;

func _ready():
	playerRef = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if playerRef != null:
		var playerDir = playerRef.position - position;
		velocity = playerDir.normalized() * SPEED * delta;
	
	
	move_and_collide(velocity)
