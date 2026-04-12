extends Control


@onready var main_menu = $MainMenu
@onready var level_select = $LevelSelect
@onready var settings = $Settings

var level_scenes = {
	"Stage1": "res://scenes/level_1.tscn",
	"Stage2": "res://scenes/levels/level_2.tscn",
	"Stage3": "res://scenes/level_3.tscn"
}

@onready var level_buttons = [
	$LevelSelect/Stage1,
	$LevelSelect/Stage2,
	$LevelSelect/Stage3
]

func _ready():
	$MainMenu/Start.pressed.connect(_on_start_pressed)
	$MainMenu/Options.pressed.connect(_on_options_pressed)
	$MainMenu/Quit.pressed.connect(_on_quit_pressed)
	$LevelSelect/Back.pressed.connect(_show_main_menu)
	$Settings/Back.pressed.connect(_show_main_menu)
	
	for btn in level_buttons:
		btn.pressed.connect(_on_level_button_pressed.bind(btn.name))
	
	_show_main_menu()
	update_level_locks()

func _show_main_menu():
	main_menu.show()
	level_select.hide()
	settings.hide()

func _on_start_pressed():
	main_menu.hide()
	level_select.show()

func _on_options_pressed():
	main_menu.hide()
	settings.show()

func _on_quit_pressed():
	get_tree().quit()


func _on_level_button_pressed(level_name: String):
	if level_scenes.has(level_name):
		var scene_path = level_scenes[level_name]
		
		TransitionManager.transition_to_scene(scene_path)

func update_level_locks():
	SaveManager.load_game()
	for i in range(level_buttons.size()):
		var btn = level_buttons[i]
		if i <= SaveManager.unlocked_level:
			btn.disabled = false
			btn.modulate = Color(1, 1, 1)
		else:
			btn.disabled = true
			btn.modulate = Color(0.3, 0.3, 0.3)
