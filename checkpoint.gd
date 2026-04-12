extends Node3D

@onready var respawn_point: Marker3D = $RespawnPoint
@onready var popup_label: Label3D = $Label3D
@onready var detection_area: Area3D = $DetectionArea

var is_active: bool = false

func _ready() -> void:
	popup_label.hide()

func show_popup() -> void:
	popup_label.show()
	
	await get_tree().create_timer(2.5).timeout
	
	popup_label.hide()

func get_spawn_position() -> Vector3:
	return respawn_point.global_position

func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players") and not is_active:
		is_active = true

		popup_label.global_position = body.global_position + Vector3(0, 2.5, 0)
		show_popup()
