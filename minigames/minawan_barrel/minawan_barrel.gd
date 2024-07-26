extends Node2D

var current_minawan: String = "RickWan"

func _ready() -> void:
	$Playable/SelectedMinawan.visible = false

	var minawan: String = "RickWan"
	if randi_range(0, 10) != 0:
		minawan = Global.personalized_minawan.pick_random()

	current_minawan = minawan
	$Playable/SelectedMinawan.texture = load("res://minawan/%s.png" % minawan)

func _start_game() -> void:
	Global.game_start.emit()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		Global.is_playing = false
		Global.change_scene_to("main_menu_scene")

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("action"):
		if not Global.is_playing:
			return

		Global.game_end.emit()

		$Playable/SelectedMinawan.visible = true
		$UI/RestartText.text = "You've caught %s!\n%s" % [current_minawan, $UI/RestartText.text]
		$Playable/Berber.frame = 2 if current_minawan in ["RickWan", "CJwan"] else 1

		$UI/AnimationPlayer.play("game_win")
		$Sounds/BGM.stop()
		$Sounds/Airhorn.play()
