extends Node2D

const TRIES: int = 30
const GEESE_TO_BONUS: int = 20

const SCORE_POINT: int = 25
const BONUS_POINTS: int = 5000

@onready var game_handle: ColorRect = $Game/Visuals/Handle
@onready var arrow: PathFollow2D = $Game/Arrow/PathFollow2D

var handle_split: float = 0.0
var scored: int = 0
var tries_left: int = TRIES

var input_pause: bool = false

func _ready() -> void:
	_update_ui()
	handle_split = (game_handle.size.x - 50.0) / TRIES

func _start_game() -> void:
	$Game/AnimationPlayer.play("moving")
	Global.game_start.emit()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		Global.is_playing = false
		get_tree().change_scene_to_packed(Global.main_menu_scene)

	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

	if Input.is_action_just_pressed("action"):
		if not Global.is_playing or input_pause:
			return
		
		input_pause = true
		$Sounds/Shoot.play()
		$Game/AnimationPlayer.speed_scale = 0
		
		tries_left -= 1
		if _is_in_bounds(arrow.progress, Vector2(game_handle.position.x, game_handle.position.x + game_handle.size.x)):
			$Sounds/Hoop.play()
			$Game/Sprites/AnimationPlayer.play("scored")
			scored += 1
			game_handle.size.x -= handle_split
			game_handle.position.x += handle_split / 2
		else:
			$Game/Sprites/AnimationPlayer.play("missed")
			
		await $Game/Sprites/AnimationPlayer.animation_finished
		_update_ui()
		
		if tries_left == 0:
			Global.game_end.emit()
			_game_end()
		
		$Game/AnimationPlayer.speed_scale = 1
		$Game/AnimationPlayer.seek(0)
		input_pause = false

func _game_end() -> void:
	$UI/AnimationPlayer.play("game_win")
	$Game/Sprites/AnimationPlayer.play("win")
	$Game/AnimationPlayer.stop()
	$Sounds/Win.play()

func _update_ui() -> void:
	$UI/ScoredText.text = str(scored)
	$UI/ScoreText.text = str(scored * SCORE_POINT)
	$UI/GeeseLeftText.text = str(tries_left)

func _is_in_bounds(value: float, bounds: Vector2) -> bool:
	return value >= bounds.x and value <= bounds.y
