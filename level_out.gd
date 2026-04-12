extends Area3D

@export var menu_scene_path: String = "res://scenes/start_menu.tscn"
@export var this_level_index: int = 0

var players_inside: Array[Node3D] = []
var is_transitioning: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
	if is_transitioning:
		return

	if body.is_in_group("Players"):
		if not players_inside.has(body):
			players_inside.append(body)
			
		_check_for_transition()

func _on_body_exited(body: Node3D) -> void:
	if is_transitioning:
		return
		
	if body.is_in_group("Player"):
		if players_inside.has(body):
			players_inside.erase(body)

func _check_for_transition() -> void:
	if players_inside.size() >= 2:
		is_transitioning = true
		$CollisionShape3D.set_deferred("disabled", true)
		SaveManager.level_completed(this_level_index)
		TransitionManager.transition_to_scene(menu_scene_path)
