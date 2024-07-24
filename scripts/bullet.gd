extends CharacterBody2D

class_name Bullet

var direction = Vector2(0, 0);

@export var speed = 400000;
var damage : float = 0;


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	velocity = direction.normalized() * speed * delta;
	global_position += velocity;
	pass

func _on_area_2d_body_entered(body):
	#print("collider")
	if (body != null) and (body is Enemy):
		body.knockback(direction);
		body.hit();
		body.takeDamage(damage);
		queue_free(); # Remove the bullet
