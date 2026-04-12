extends StaticBody3D

@onready var world_1: Node3D = $"../World1"
@onready var world_2: Node3D = $"../World2"
@onready var click: AudioStreamPlayer3D = $Click

var in_mirror := false

func _ready() -> void:
	world_2.visible = false
	world_2.process_mode = Node.PROCESS_MODE_DISABLED
	world_1.visible = true
	world_1.process_mode = Node.PROCESS_MODE_INHERIT

func Interact():
	click.play()
	in_mirror = !in_mirror
	if in_mirror:
		world_1.visible = false
		world_1.process_mode = Node.PROCESS_MODE_DISABLED
		world_2.visible = true
		world_2.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		world_2.visible = false
		world_2.process_mode = Node.PROCESS_MODE_DISABLED
		world_1.visible = true
		world_1.process_mode = Node.PROCESS_MODE_INHERIT
