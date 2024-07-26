extends Node2D

const NUMBER_OF_MINAWANS: int = 9

const MINAWAN_POINT: int = 100
const BONUS_POINT: int = 5000

@onready var minawan_area: Node2D = $MinawanArea
@onready var starting_point: Vector2 = $StartingPoint.position

@onready var collision_position: Vector2 = $BerberCollisionArea/BerberCollision.global_position
@onready var collision_radius: float = $BerberCollisionArea/BerberCollision.shape.radius

@onready var display_width: int = DisplayServer.window_get_size().x
@onready var center_point: float = float(display_width) / 2

var all_minawan: Array = Global.get_minawan_list()
var minawan_entity: PackedScene = preload("res://minigames/fwoot_punch/minawan_entity.tscn")

func _ready() -> void:
	all_minawan.shuffle()
	for i in NUMBER_OF_MINAWANS:
		var minawan = minawan_entity.instantiate()
		minawan.global_position = starting_point
		minawan.minawan_texture = all_minawan.pop_front()

		minawan_area.add_child(minawan)

func _draw() -> void:
	draw_circle(collision_position, collision_radius, Color(1, 1, 1, 0.15))

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

		await get_tree().process_frame
		Global.game_end.emit()

		$UI/AnimationPlayer.play("game_win")
		var minawan_caught: int = %BerberCollisionArea.get_overlapping_areas().size()
		var points = minawan_caught * MINAWAN_POINT
		if minawan_caught == NUMBER_OF_MINAWANS:
			$UI/PerfectBonusText.visible = true
			points += BONUS_POINT
		$UI/ScoreText.text = str(points)

		$Sounds/BGM.stop()
		$Sounds/Airhorn.play()
		await $Sounds/Airhorn.finished
		$Sounds/Chant.play()
