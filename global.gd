extends Node

signal game_start()
signal game_end()

# region SCENES
static var main_menu_scene: PackedScene = preload("res://main_menu/main_menu.tscn")
static var fwoot_punch_scene: PackedScene = preload("res://minigames/fwoot_punch/fwoot_punch.tscn")
static var minawan_barrel_scene: PackedScene = preload("res://minigames/minawan_barrel/minawan_barrel.tscn")
static var microwave_hoops_scene: PackedScene = preload("res://minigames/microwave_hoops/microwave_hoops.tscn")
# endregion

@export var is_playing: bool = false
@export var is_personalized: bool = true

static var personalized_minawan: Array = []

static var standard_minawan: Array = [
    'Cerby'
]

@export_category("Fwoot Punch")
@export var punch_current_stopped_minawan: int = 0

func _init() -> void:
    var path = "res://minawan/"
    for fname in DirAccess.get_files_at(path):
        var import_name: String = fname.trim_suffix(".import")
        if fname.ends_with(".import") and ResourceLoader.exists(path + import_name):
            if fname.begins_with("RickWan"):
                continue

            if fname.begins_with("standard_"):
                standard_minawan.append(import_name.trim_suffix(".png"))
                standard_minawan.append(import_name.trim_suffix(".png")) # twice because we don't have enough
            else:
                personalized_minawan.append(import_name.trim_suffix(".png"))
                
    standard_minawan.shuffle()
    personalized_minawan.shuffle()

func _ready() -> void:
    randomize()
    game_start.connect(_on_game_start)
    game_end.connect(_on_game_end)

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("fullscreen"):
        var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if is_fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN)

    if Input.is_action_just_pressed("ui_cancel"):
        if not OS.has_feature("web"):
            get_tree().quit()

func _on_game_start() -> void:
    is_playing = true

func _on_game_end() -> void:
    is_playing = false

func get_minawan_list() -> Array:
    var list = personalized_minawan if is_personalized else standard_minawan
    return list.duplicate()

func change_scene_to(scene_name: String) -> void:
    get_tree().change_scene_to_packed(get(scene_name))