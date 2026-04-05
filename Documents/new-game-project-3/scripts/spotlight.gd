extends StaticBody3D

var on := true
var is_broken := false

enum LightState { WHITE, RED, BLUE, OFF }
var current_state: int = LightState.WHITE

@export var outline_material: Material

# Aici vom stoca absolut toate mesh-urile gasite in acest obiect
var all_meshes: Array[MeshInstance3D] = []

func _ready() -> void:
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
	if not is_broken:
		current_state = (current_state + 1) % 4
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
	rotation_degrees.y += 90.0

func _process(_delta: float) -> void:
	pass
