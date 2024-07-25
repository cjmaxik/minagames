extends Node2D

const MIN_TIMER: float = 3.0
const MAX_TIMER: float = 6.0

const MIN_SPEED: float = 0.15
const MAX_SPEED: float = 0.85

const MAX_MINAWAN_STOPPED: int = 3

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var minawan_sprite: Sprite2D = %MinawanSprite

@onready var playing_timer: Timer = %PlayingTimer
@onready var waiting_timer: Timer = %WaitingTimer

@export var animation_length: float = 0.0
@export var direction: int = 1
@export var speed: float = 1.0

var minawan_texture: String

func _ready() -> void:
	minawan_sprite.texture = load("res://minawan/%s.png" % minawan_texture)

	Global.game_start.connect(_on_game_start)
	Global.game_end.connect(_on_game_end)
	Global.punch_current_stopped_minawan = 0

	animation_length = animation_player.get_animation("moving").length
	
	var random_seek: float = randf_range(0.05, animation_length - 0.05)
	direction = -1 if randi() % 2 == 0 else 1
	speed = direction * _get_random_speed()

	_play_animation(true)
	animation_player.seek(random_seek, true)
	animation_player.pause()

	playing_timer.wait_time = _get_random_time()

func _start() -> void:
	_play_animation()
	playing_timer.start()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if not Global.is_playing:
		return

	speed *= -1
	direction = -1 if speed < 0 else 1
	_play_animation()

func _play_animation(init := false) -> void:
	if not init and not Global.is_playing:
		return

	var resulted_direction = true if direction == -1 else false
	minawan_sprite.flip_h = resulted_direction
	animation_player.play("moving", -1, speed, resulted_direction)

func _on_playing_timer_timeout() -> void:
	if not Global.is_playing:
		return

	var random_time = _get_random_time()
	var random_chance = randi_range(0, 2)

	if random_chance == 0 or Global.punch_current_stopped_minawan >= MAX_MINAWAN_STOPPED:
		# Change speed
		var seek: float = animation_player.current_animation_position
		speed = direction * _get_random_speed()
		animation_player.seek(seek)
		_play_animation()
		
		playing_timer.wait_time = random_time
		playing_timer.start()
	else:
		# Stop for a while
		Global.punch_current_stopped_minawan += 1
		animation_player.speed_scale = 0
		waiting_timer.wait_time = random_time
		waiting_timer.start()

func _on_waiting_timer_timeout() -> void:
	Global.punch_current_stopped_minawan -= 1
	animation_player.speed_scale = 1

	playing_timer.wait_time = _get_random_time()
	playing_timer.start()

func _on_game_start() -> void:
	_start()

func _on_game_end() -> void:
	playing_timer.stop()
	waiting_timer.stop()

	animation_player.speed_scale = 1
	var got_caught = false
	var areas: Array = %Area2D.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("berber_collision_area"):
			got_caught = true
			break
	
	if got_caught:
		animation_player.play("game_end")
		await animation_player.animation_finished
	else:
		modulate.a = 0.5
	animation_player.pause()

func _flip_sprite() -> void:
	minawan_sprite.flip_h = true if direction == 1 else false

func _get_random_speed() -> float:
	return randf_range(MIN_SPEED, MAX_SPEED)

func _get_random_time() -> float:
	return randf_range(MIN_TIMER, MAX_TIMER)
