extends Node2D

func _ready() -> void:
	Global.is_playing = false
	_update_minawan_button()
	_update_credits()
	
func _on_standard_minawan_toggled(toggled_on: bool) -> void:
	Global.is_personalized = toggled_on
	_update_minawan_button()

func _update_minawan_button() -> void:
	%MinawanType.set_pressed_no_signal(Global.is_personalized)
	if Global.is_personalized:
		%MinawanType.text = "Personalized"
	else:
		%MinawanType.text = "Standard"

func _update_credits() -> void:
	var minawan = Global.personalized_minawan.reduce(func(a, b): return a + ', ' + b)
	$UI/Help/CreditsText.text = $UI/Help/CreditsText.text % minawan

func _on_fwoot_punch_button_pressed() -> void:
	get_tree().change_scene_to_packed(Global.fwoot_punch_scene)

func _on_minawan_barrel_button_pressed() -> void:
	get_tree().change_scene_to_packed(Global.minawan_barrel_scene)
