extends Node3D

@onready var dialogue_ui = $PanelContainer
@onready var label = $PanelContainer/Label
@onready var invisible_wall = $InvisibleWall
@onready var invisible_wall_2 = $InvisibleWall2

@export var safe_spot: Vector3 = Vector3(-93, 0, -40)

var dialogue_1: Array[String] = [
	"Why do you still try?",
	"It should be obvious by now, that there's no way out.",
	"This is your fault.",
	"But fine. I will continue to help you. Even if you don't know who I am.",
    "Press that button."
]
var dialogue_2: Array[String] = [
	"You made me this way.",
	"Everything about yourself that you hated, that you couldn't face...",
	"You threw it all out, creating me.",
    "You are nothing without me."
]
var dialogue_3: Array[String] = [
	"This place, too, exists because of you.",
	"If you keep denying my existence, we will be trapped here forever. Running in circles.",
    "The only way out is..."
]

var active_dialogue: Array[String] = []
var current_line: int = 0
var current_phase: int = 0

var sequence_id: int = 0 

func _ready():
	await get_tree().create_timer(3.0).timeout
	start_dialogue(dialogue_1, 1)

func start_dialogue(lines: Array[String], phase: int):
	if dialogue_ui.visible:
		apply_phase_effects(current_phase)

	sequence_id += 1
	active_dialogue = lines
	current_phase = phase
	current_line = 0
	dialogue_ui.show()
	show_current_line()

func advance_dialogue():
	current_line += 1 
	
	if current_line < active_dialogue.size():
		show_current_line()
	else:
		finish_dialogue()

func show_current_line():
	label.text = active_dialogue[current_line]
	check_dialogue_events()
	
	var expected_sequence = sequence_id
	
	await get_tree().create_timer(3.0).timeout
	
	if sequence_id == expected_sequence and dialogue_ui.visible:
		advance_dialogue()

func check_dialogue_events():
	pass

func finish_dialogue():
	dialogue_ui.hide()
	apply_phase_effects(current_phase)

func apply_phase_effects(phase: int):
	if phase == 1 and is_instance_valid(invisible_wall):
		invisible_wall.queue_free()
	elif phase == 2 and is_instance_valid(invisible_wall_2):
		invisible_wall_2.queue_free()

func _on_area_1_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		start_dialogue(dialogue_2, 2)
		$"Area 1".queue_free() 

func _on_area_2_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		start_dialogue(dialogue_3, 3)
		$"Area 2".queue_free()
