extends CharacterBody3D

var direction: Vector2
var speed := 30.0
var acceleration := 8.0
var friction := 12.0
@onready var camera: Node3D = $"../Camera"
@onready var roc: AudioStreamPlayer3D = $roc

var is_fading_out: bool = false
var fade_tween: Tween

@onready var skin = $"Root Scene"
@onready var move_state_machine = $"Root Scene/AnimationTree".get("parameters/Movement/playback")


var time_in_light: float = 0.0
var time_to_die: float = 1.5
var safe_position: Vector3

var current_obj : Node3D = null

func _ready() -> void:
	safe_position = global_position

func start_fade_out():
	is_fading_out = true
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	for node in get_children_recursive(self):
		if node is MeshInstance3D:
			fade_tween.parallel().tween_property(node, "transparency", 1.0, 1.5)

func start_fade_in():
	is_fading_out = false
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
	fade_tween = create_tween()
	for node in get_children_recursive(self):
		if node is MeshInstance3D:
			fade_tween.parallel().tween_property(node, "transparency", 0.0, 1.0)

func _physics_process(delta: float) -> void:
	if not is_in_light():
		if not is_fading_out:
			start_fade_out()
		time_in_light += delta
		if time_in_light >= time_to_die:
			teleport_darkness()
			start_fade_in()
			time_in_light = 0.0
	else:
		if is_fading_out:
			start_fade_in()
		time_in_light = max(0.0, time_in_light - delta)
	get_input()
	move(delta)
	
	var raw_push_dir = Vector3(velocity.x, 0, velocity.z).normalized()
	
	var push_dir = Vector3.ZERO
	if raw_push_dir != Vector3.ZERO:
		if abs(raw_push_dir.x) > abs(raw_push_dir.z):
			push_dir = Vector3(sign(raw_push_dir.x), 0, 0)
		else:
			push_dir = Vector3(0, 0, sign(raw_push_dir.z))
	
	move_and_slide()
	
	var is_pushing := false
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			if abs(collision.get_normal().y) < 0.1:
				if push_dir != Vector3.ZERO and push_dir.dot(-collision.get_normal()) > 0.5:
					var push_force = 3.0
					collider.apply_central_impulse(push_dir * push_force)
					is_pushing = true

	if is_pushing and push_dir != Vector3.ZERO:
		var forward_speed = Vector3(velocity.x, 0, velocity.z).dot(push_dir)
		velocity.x = push_dir.x * forward_speed
		velocity.z = push_dir.z * forward_speed
		if not roc.playing:
			roc.play()
	animate(delta)

func get_input():
	direction = Input.get_vector("p1left","p1right","p1up","p1down").rotated(-camera.global_rotation.y)
	if Input.is_action_just_pressed("ui_cancel"):
		$AnimationTree.set("parameters/HitOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func _input(_event):
	if is_instance_valid(current_obj):
		if Input.is_action_just_pressed("interact") and current_obj.has_method("Interact"):
			current_obj.Interact()
		elif Input.is_action_just_pressed("rotate") and current_obj.has_method("Rotate"):
				current_obj.Rotate()

func move(delta):
	var vel_2d := Vector2(velocity.x, velocity.z)
	if direction:
		vel_2d += direction * speed * delta * acceleration
		vel_2d = vel_2d.limit_length(speed)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
	else:
		vel_2d = vel_2d.move_toward(Vector2.ZERO, speed * friction * delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y

func animate(delta):
	move_state_machine.travel('Run' if direction else 'Idle')
	if direction:
		skin.rotation.y = rotate_toward(skin.rotation.y,-direction.angle() + PI/2, 6.0 * delta)

func fade_out_everything(duration: float):
	var tween = create_tween()
	for node in get_children_recursive(self):
		if node is MeshInstance3D:
			node.transparency = 0.0
			tween.parallel().tween_property(node, "transparency", 1.0, duration)

func get_children_recursive(from_node: Node) -> Array:
	var nodes = []
	for child in from_node.get_children():
		nodes.append(child)
		nodes.append_array(get_children_recursive(child))
	return nodes

func is_in_light() -> bool:
	var space = get_world_3d().direct_space_state
	var start_pos = global_position + Vector3(0, 1, 0)
	var lights = get_tree().get_nodes_in_group("lumini")
	for light_node in lights:
		var actual_light = light_node
		if light_node is Area3D:
			actual_light = light_node.get_parent()
		if actual_light.on == false:
			continue
		var spotlight_node = actual_light.get_node("SpotLight3D")
		var end_pos = spotlight_node.global_position
		var light_pos = spotlight_node.global_position
		var distance_to_light = start_pos.distance_to(light_pos)
		if distance_to_light > spotlight_node.spot_range - 5.0:
			continue
		var dir_to_player = (start_pos - light_pos).normalized()
		var light_forward = -spotlight_node.global_transform.basis.z.normalized()
		if light_forward.dot(dir_to_player) > 0.7:  
			var ray = PhysicsRayQueryParameters3D.create(start_pos, end_pos, 1, [get_rid(), actual_light.get_rid()])
			ray.hit_from_inside = true
			var result = space.intersect_ray(ray)
			if result.is_empty():
				return true
	return false

func teleport_darkness() -> void:
	global_position = safe_position
	time_in_light = 0.0


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Checkpoint1"):
		var checkpoint_scene = area.get_parent()
		if checkpoint_scene.has_method("get_spawn_position"):
			safe_position = checkpoint_scene.get_spawn_position()
		return
		
	current_obj = area.get_parent()
	if current_obj.has_method("toggle_outline"):
		current_obj.toggle_outline(true)

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent() == current_obj:
		if current_obj.has_method("toggle_outline"):
			current_obj.toggle_outline(false)
		current_obj = null
