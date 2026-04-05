extends CharacterBody3D


const SPEED = 15.0
const JUMP_VELOCITY = 4.5

var time_in_light: float = 0.0
var time_to_die: float = 1.5

var safe_position: Vector3

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
			var result = space.intersect_ray(ray)
			if result.is_empty():
				return true
				
	return false

func teleport_darkness() -> void:
	global_position = safe_position
	time_in_light = 0.0

func _physics_process(delta: float) -> void:
	if is_in_light():
		time_in_light += delta
		if time_in_light >= time_to_die:
			teleport_darkness();
	else:
		time_in_light = max(0.0, time_in_light - delta)
		safe_position = global_position
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	move()
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is RigidBody3D:
			var push_dir = -collision.get_normal()
			push_dir.y = 0
			var push_force = 0.5
			collider.apply_central_impulse(push_dir * push_force)


func move():
	var input_dir := Input.get_vector("p2left", "p2right", "p2up", "p2down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

var current_obj : Node3D = null

func _input(_event):
	if is_instance_valid(current_obj):
		if Input.is_action_just_pressed("interact") and current_obj.has_method("Interact"):
			current_obj.Interact()
		elif Input.is_action_just_pressed("rotate") and current_obj.has_method("Rotate"):
				current_obj.Rotate()

func _ready() -> void:
	safe_position = global_position

func _on_area_3d_area_entered(area: Area3D) -> void:
	current_obj = area.get_parent()
	if current_obj.has_method("toggle_outline"):
		current_obj.toggle_outline(true)
		

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.get_parent() == current_obj:
		if current_obj.has_method("toggle_outline"):
			current_obj.toggle_outline(false)
		current_obj = null
