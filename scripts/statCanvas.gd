extends CanvasLayer

var player : Player;

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_first_node_in_group("player");
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$statNum.text = str(player.level) + "\n" \
					+ str(player.HP) + "/" + str(player.maxHP) \
					+ "\n" + str(player.power) + "\n" \
					+ str(player.EXP) + "/" + str(player.maxEXP) + "\n" \
					+ str(player.gun.ammoCounter) + "/" + str(player.gun.gunType.ammo);
	if (player.gun.reloading):
		$statNum.text += "\nReloading";
	pass
