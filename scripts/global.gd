extends Node


func shake_camera(aimDir : Vector2) -> void:
	get_viewport().get_camera_2d().apply_shake(aimDir);

func stop_time(time : float, scale : float = 0.1):
	Engine.time_scale = clamp(scale, 0, 1);
	await get_tree().create_timer(time, true, false, true).timeout;
	Engine.time_scale = 1;
