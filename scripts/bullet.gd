extends CharacterBody2D

class_name Bullet

var direction = Vector2(0, 0);

@export var speed = 400000;
var damage : float = 0;
var fireRate: float = 0;
var lifeTime : float = 3;
var effects : Array[Resource];

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	lifeTime -= delta;
	if (lifeTime <= 0):
		queue_free();

func _physics_process(delta):
	velocity = direction.normalized() * speed * delta;
	global_position += velocity;
	pass

func _on_area_2d_body_entered(body):
	#print("collider")
	if (body != null) and (body is Enemy):
		body.knockback(direction);
		for effect in effects:
			var effectNode : Node2D = Node2D.new();
			effectNode.set_script(effect);
			body.add_child(effectNode);

		body.hit();
		body.takeDamage(damage);
		queue_free(); # Remove the bullet
