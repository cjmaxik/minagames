extends Node2D

func _ready() -> void:
	Global.is_playing = false
	_update_minawan_button()
	_update_credits()

	for node in _get_all_children(self):
		if node is Button:
			node.mouse_entered.connect(_play_blip)
	
func _on_standard_minawan_toggled(toggled_on: bool) -> void:
	_play_put()
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
	await _play_put()
	Global.change_scene_to("fwoot_punch_scene")

func _on_minawan_barrel_button_pressed() -> void:
	await _play_put()
	Global.change_scene_to("minawan_barrel_scene")

func _on_microwave_hoops_button_pressed() -> void:
	await _play_put()
	Global.change_scene_to("microwave_hoops_scene")

func _play_blip() -> void:
	$Sounds/Blip.play()

func _play_put() -> void:
	$Sounds/Put.play()
	await $Sounds/Put.finished

func _get_all_children(in_node, array := []):
	array.push_back(in_node)
	for child in in_node.get_children():
		array = _get_all_children(child, array)
	return array
