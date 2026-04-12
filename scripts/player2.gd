extends CharacterBody3D

var direction: Vector2
var speed := 30.0
var acceleration := 8.0
var friction := 12.0
@onready var roc: AudioStreamPlayer3D = $roc

@onready var gpu_particles_3d: GPUParticles3D = $SHADOWGUY/GPUParticles3D
@onready var camera: Camera3D = $"../Camera/Camera3D"
@onready var skin = $SHADOWGUY
@onready var move_state_machine = $SHADOWGUY/AnimationTree.get("parameters/Movement/playback")

var safe_position: Vector3
var time_in_light: float = 0.0
var time_to_die: float = 1.5
var current_obj: Node3D = null

func _ready() -> void:
	safe_position = global_position

func _physics_process(delta: float) -> void:
	if is_in_light():
		gpu_particles_3d.emitting = true
		time_in_light += delta
		if time_in_light >= time_to_die:
			teleport_darkness()
	else:
		gpu_particles_3d.emitting = false
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
	direction = Input.get_vector("p2left","p2right","p2up","p2down").rotated(-camera.global_rotation.y)

	if Input.is_action_just_pressed("ui_cancel"):
		$AnimationTree.set("parameters/HitOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


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

func is_in_light(target_pos: Vector3 = Vector3.ZERO) -> bool:
	var space = get_world_3d().direct_space_state
	
	var check_pos = global_position if target_pos == Vector3.ZERO else target_pos
	check_pos += Vector3(0, 1.0, 0) 
	
	var lights = get_tree().get_nodes_in_group("lumini")

	for light_node in lights:
		var actual_light = light_node
		if light_node is Area3D:
			actual_light = light_node.get_parent()
		if actual_light.on == false:
			continue

		var spotlight_node = actual_light.get_node("SpotLight3D")
		var light_pos = spotlight_node.global_position
		var distance_to_light = check_pos.distance_to(light_pos)

		if distance_to_light > spotlight_node.spot_range:
			continue

		var dir_to_player = (check_pos - light_pos).normalized()
		var light_forward = -spotlight_node.global_transform.basis.z.normalized()

		if light_forward.dot(dir_to_player) > 0.6:
			var ray = PhysicsRayQueryParameters3D.create(light_pos, check_pos)
			ray.exclude = [get_rid()]
			var result = space.intersect_ray(ray)
			if result.is_empty():
				return true
	return false

func teleport_darkness() -> void:
	global_position = safe_position
	time_in_light = 0.0

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Checkpoint2"):
		var checkpoint_scene = area.get_parent()
		if checkpoint_scene.has_method("get_spawn_position"):
			safe_position = checkpoint_scene.get_spawn_position()
		return
