extends Node3D

@onready var dialogue_ui = $PanelContainer
@onready var label = $PanelContainer/Label
@onready var invisible_wall = $InvisibleWall
@onready var invisible_wall_2 = $InvisibleWall2

@onready var spotlight_1 = $Spotlight
@onready var spotlight_2 = $Spotlight5

@export var safe_spot: Vector3 = Vector3(-93, 0, -40)

var dialogue_1: Array[String] = [
	"Welcome to the tutorial!",
	"In case you haven't noticed yet, your shadow has left you.",
	"Without a shadow, the darkness will slowly swallow you whole.", 
	"Similarly, your shadow will burn up in the light.",
	"However, neither of you are complete without the other. So you must work together in order to escape."
]
var dialogue_2: Array[String] = [
	"See these spotlights? They may either help you or hinder you on your way out.",
	"You can interact with them or, in some cases, even rotate them as you see fit.",
	"Try turning them off or rotating them so your shadow can pass."
]
var dialogue_3: Array[String] = [
	"In order to finish the level, enter the box on the right."
]

var active_dialogue: Array[String] = []
var current_line: int = 0
var current_phase: int = 0

var sequence_id: int = 0 

func _ready():
	await get_tree().create_timer(3.0).timeout
	start_dialogue(dialogue_1, 1)

func start_dialogue(lines: Array[String], phase: int):
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
	if current_phase == 2:
		match current_line:
			0: 
				spotlight_1.toggle_outline(true)
				spotlight_2.toggle_outline(true)
			1:
				spotlight_1.toggle_outline(false)
				spotlight_2.toggle_outline(false)

func finish_dialogue():
	dialogue_ui.hide()
	if current_phase == 1:
		if invisible_wall:
			invisible_wall.queue_free()
	if current_phase == 2:
		if invisible_wall_2:
			invisible_wall_2.queue_free()

func _on_area_1_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		start_dialogue(dialogue_2, 2)
		$"Area 1".queue_free()

func _on_area_2_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		start_dialogue(dialogue_3, 3)
		$"Area 2".queue_free()
