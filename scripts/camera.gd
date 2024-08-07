extends Camera2D

@export var randomStrength: float = 30.0;
@export var shakeFade: float = 12.0;
@export var OFFSET_MAX_DIST = 10;

var rng = RandomNumberGenerator.new();

var shakeStrength: float = 0.0;
var player : Player;
var shakeOffset: Vector2;
var shakeDir : Vector2 = Vector2.ZERO;

func _ready():
	player = get_tree().get_first_node_in_group("player") as Player;
	print(player);
	pass 

func _process(delta):
	if shakeStrength > 0:
		shakeStrength = lerpf(shakeStrength, 0, shakeFade * delta);
		shakeOffset = randomOffset();
		
	var target: Vector2 = Vector2.ZERO;
	if player != null:
		var centerPos = position;
		var mousePos = get_mouse_position_in_world();
		var direction = centerPos.direction_to(mousePos);
		# world to viewport position
		var distance = get_mouse_position_in_viewport();
		distance = distance * 2 - Vector2.ONE;
		target = direction * distance.length() * OFFSET_MAX_DIST;
	
	position = player.position + target + shakeOffset;
	pass

func get_mouse_position_in_world() -> Vector2:
	var mousePos = get_viewport().get_mouse_position();
	mousePos = mousePos.clamp(Vector2.ZERO, get_viewport_rect().size);
	# convert to world position
	mousePos = get_canvas_transform().affine_inverse() * mousePos;
	return mousePos;
	
func get_mouse_position_in_viewport() -> Vector2:
	var mousePos = get_viewport().get_mouse_position();
	mousePos = mousePos.clamp(Vector2.ZERO, get_viewport_rect().size);
	mousePos /= get_viewport_rect().size;
	return mousePos;

func apply_shake(dir : Vector2 = Vector2.ZERO):
	shakeStrength = randomStrength;
	shakeDir = dir.normalized();

func randomOffset() -> Vector2:
	if (shakeDir == Vector2.ZERO):
		return Vector2(rng.randf_range(-shakeStrength, shakeStrength),
			rng.randf_range(-shakeStrength, shakeStrength));
	return shakeDir * rng.randf_range(-shakeStrength, shakeStrength);
