extends Timer

@export var mob_scene: PackedScene;
@export var spawnSize : Vector2;
var player : Player;
var camera : Camera2D;
var viewportSize : Vector2;
@onready var line : Line2D = $Line2D;

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player");
	camera = get_viewport().get_camera_2d();
	viewportSize = get_viewport().get_visible_rect().size;
	#for i in range(1, 5):
	#	spawn_mob();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	# Debug draw
	'''
	line.clear_points();
	var spawnPos : Vector2 = Vector2.ZERO;
	var outterScreenPosX : Vector2 = \
		Vector2(camera.get_screen_center_position().x - viewportSize.x / 2,
				camera.get_screen_center_position().x + viewportSize.x / 2);
	var outterScreenPosY : Vector2 = \
		Vector2(camera.get_screen_center_position().y - viewportSize.y / 2,
				camera.get_screen_center_position().y + viewportSize.y / 2);\
	line.add_point(Vector2(outterScreenPosX.x, outterScreenPosY.x));
	line.add_point(Vector2(outterScreenPosX.x, outterScreenPosY.y));
	line.add_point(Vector2(outterScreenPosX.y, outterScreenPosY.y));
	line.add_point(Vector2(outterScreenPosX.y, outterScreenPosY.x));
	line.add_point(Vector2(outterScreenPosX.x, outterScreenPosY.x));
	'''
	pass


func spawn_mob() -> void:
	#if $MobTimer.wait_time < 1:
	#	$MobTimer.wait_time = 0.5;
	#else:
	wait_time = max(4.0/player.level, 0.01);
	var mob = mob_scene.instantiate();
	# Choose a random location on Path2D.
	var spawnPos : Vector2 = Vector2.ZERO;
	var outterScreenPosX : Vector2 = \
		Vector2(camera.get_screen_center_position().x - viewportSize.x / 2,
				camera.get_screen_center_position().x + viewportSize.x / 2);
	var outterScreenPosY : Vector2 = \
		Vector2(camera.get_screen_center_position().y - viewportSize.y / 2,
				camera.get_screen_center_position().y + viewportSize.y / 2);

	if (randi_range(0, 1) == 0):
		spawnPos.x = randf_range(outterScreenPosX.x - spawnSize.x, \
			outterScreenPosX.x);
	else:
		spawnPos.x = randf_range(outterScreenPosX.y, \
			spawnSize.x + outterScreenPosX.y);
	
	if (randi_range(0, 1) == 0):
		spawnPos.y = randf_range(outterScreenPosY.x - spawnSize.y,\
			outterScreenPosY.x);
	else:
		spawnPos.y = randf_range(outterScreenPosY.y, \
			spawnSize.y + outterScreenPosY.y);
	var mob_spawn_location = $"../Path2D/PathFollow2D";
	mob_spawn_location.progress_ratio = randf();
	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2;
	# Set the mob's position to a random location.
	mob.global_position = spawnPos;
	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4);
	#mob.rotation = direction;
	# Spawn the mob by adding it to the Main scene.
	add_child(mob);


func _on_timeout():
	spawn_mob();
	pass # Replace with function body.
