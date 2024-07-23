extends RigidBody2D

var direction = Vector2(0, 0);
var speed = 400000;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(delta):
	linear_velocity = direction.normalized() * speed * delta;
	
	
	pass

