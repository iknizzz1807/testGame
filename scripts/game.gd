extends Node2D

@export var mob_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_mob_timer_timeout(): # Spawn the enemy
	var mob = mob_scene.instantiate()
	# Choose a random location on Path2D.
	var mob_spawn_location = $Path2D/PathFollow2D
	mob_spawn_location.progress_ratio = randf()
	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2
	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position
	# Add some randomness to the direction.
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)

func _on_player_die_event():
	# Game over
	Engine.time_scale = 0; # Stop the entire game with no exception
	get_tree().paused = true; # Stop only the physics in the game
	pass # Replace with function body.
