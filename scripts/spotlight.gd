extends StaticBody3D

var on := true
var is_broken := false

enum LightState { WHITE, RED, BLUE, OFF }
var current_state: int = LightState.WHITE
@onready var click: AudioStreamPlayer3D = $Click
@export var outline_material: Material

@export_group("states")
@export var allow_white: bool = true
@export var allow_red: bool = false
@export var allow_blue: bool = false
@export var allow_off: bool = true
@export var rotatable: bool = true

var active_states: Array[LightState] = []
var current_state_index: int = 0

var all_meshes: Array[MeshInstance3D] = []

func _ready() -> void:
	if allow_white: active_states.append(LightState.WHITE)
	if allow_red: active_states.append(LightState.RED)
	if allow_blue: active_states.append(LightState.BLUE)
	if allow_off: active_states.append(LightState.OFF)
	
	if active_states.is_empty():
		active_states.append(LightState.OFF)
	
	current_state = active_states[0]
	
	update_light_visuals()
	find_all_meshes(self)

func find_all_meshes(node: Node) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			all_meshes.append(child)
		find_all_meshes(child)

func break_bec() -> void:
	if not is_broken:
		is_broken = true
		on = false
		$SpotLight3D.visible = false
		toggle_outline(false)

func toggle_outline(is_hovered: bool):
	for mesh in all_meshes:
		if is_hovered and not is_broken:
			mesh.material_overlay = outline_material
		else:
			mesh.material_overlay = null

func Interact():
	click.play()
	if not is_broken and active_states.size() > 1:
		current_state_index = (current_state_index + 1) % active_states.size()
		current_state = active_states[current_state_index]
		update_light_visuals()

func update_light_visuals():
	match current_state:
		LightState.WHITE:
			$SpotLight3D.visible = true
			$SpotLight3D.light_color = Color.WHITE
			on = true
		LightState.RED:
			$SpotLight3D.visible = true
			$SpotLight3D.light_color = Color.RED
			on = true
		LightState.BLUE:
			$SpotLight3D.visible = true
			$SpotLight3D.light_color = Color.BLUE
			on = true
		LightState.OFF:
			$SpotLight3D.visible = false
			on = false

func Rotate():
	click.play()
	if rotatable == true:
		rotation_degrees.y += 90.0

func _process(_delta: float) -> void:
	pass
