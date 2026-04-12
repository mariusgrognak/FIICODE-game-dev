extends Node3D

@export var player1: CharacterBody3D
@export var player2: CharacterBody3D


@export var follow_speed: float = 5.0
@export var min_camera_height: float = 5.0
@export var zoom_speed: float = 3.0

@export var camera_offset: Vector3 = Vector3(0, 5, 8) 

func _process(delta: float) -> void:
	if not player1 or not player2:
		return

	var center_pos = (player1.global_position + player2.global_position) / 2.0
	
	global_position = global_position.lerp(center_pos, follow_speed * delta)

	var distance = player1.global_position.distance_to(player2.global_position)

	var desired_zoom = max(min_camera_height, distance * 0.8)

	var camera = get_child(0)
	
	var target_camera_pos = camera_offset.normalized() * desired_zoom
	
	camera.position = camera.position.lerp(target_camera_pos, zoom_speed * delta)
	
	camera.look_at(global_position)
