extends Sprite2D

@export var maxHeight : float = 50;
@onready var shadowHeight = global_position.y + maxHeight; # + is down
@export var rotDegrees : float = 35;
@export var speed : float = 150;
@export var gravity : float = 20;
@export var vspMax : float = -400;
#@export var angle : float = 30;
@export_range(0, 1) var friction : float = 0.7;
#var velocity : Vector2 = Vector2.ONE;
@export var killTime : float = 3;
var killTimer = killTime;
var vsp = vspMax * 0.6;

func _ready():
	speed *= -sign(scale.x);
	shadowHeight += randf_range(-1, 1) * 10;
	speed *= randf_range(0.7, 1.4);
	vspMax *= randf_range(0.7, 1.4);

func _process(delta):
	killTimer -= delta;
	if (killTimer <= 0): queue_free();
	if (is_zero_approx(vspMax)):
		return;
	rotation_degrees += rotDegrees;
	# go up = -
	# go down = +
	position.x += speed * delta;
	position.y += vsp * delta;
	vsp += gravity;
	if (global_position.y >= shadowHeight):
		vspMax *= friction;
		speed *= friction;
		vsp = vspMax;
		rotDegrees *= friction;
	
