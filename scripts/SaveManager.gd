extends Node

const SAVE_PATH = "user://savegame.save"

var unlocked_level: int = 0 

func _ready():
	load_game()

func level_completed(just_finished_index: int):
	if just_finished_index >= unlocked_level:
		unlocked_level = just_finished_index + 1
		save_game()
		print("Level Unlocked! Now at: ", unlocked_level)

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(unlocked_level)
		file.close()

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			unlocked_level = file.get_var()
			file.close()
