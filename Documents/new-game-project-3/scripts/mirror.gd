extends StaticBody3D


@onready var world_1: Node3D = $"../world1"
@onready var world_2: Node3D = $"../world2"

@onready var world_parent = world_1.get_parent()

var in_mirror := false


func _ready() -> void:
	if world_2.is_inside_tree():
		world_parent.remove_child.call_deferred(world_2)


func display_text(val: bool):
	$Label3D.visible = val
	
func Interact():
	in_mirror = !in_mirror
	if world_1.is_inside_tree():
		world_parent.remove_child(world_1)
		world_parent.add_child(world_2)
	else:
		world_parent.remove_child(world_2)
		world_parent.add_child(world_1)

func _process(_delta: float) -> void:
	pass
