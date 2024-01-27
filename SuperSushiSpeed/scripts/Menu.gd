extends Control

var API_KEY = "prod_4135c08094c1428cbe83647654cf6a81"
var player_identifier: String

func _ready():
	var de = FileAccess.open("res://usersave/user_login.json", FileAccess.READ)
	var data = JSON.parse_string(de.get_as_text())
	de.close()
	var popup = get_node("../Panel")
	var pseudo = get_node("Pseudo")
	if data["player_identifier"] == null:
		popup.set_visible(true)
	else:
		popup.set_visible(false)
		pseudo.set_visible(true)
		player_identifier = data["player_identifier"]
		var hearders = PackedStringArray(["Content-Type: application/json"])
		var game = JSON.new().stringify({
			"game_key" : API_KEY,
			"player_identifier": player_identifier,
			"game_version": "0.1.0"
		})
		var connectCurrent = HTTPRequest.new()
		add_child(connectCurrent)
		connectCurrent.request(
			"https://api.lootlocker.io/game/v2/session/guest",
			hearders,
			HTTPClient.METHOD_POST,
			game
		)
		connectCurrent.request_completed.connect(_on_request_completed)
		

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	var session_token = json["session_token"]
	var de = FileAccess.open("res://usersave/session.json", FileAccess.WRITE)
	de.store_string(JSON.new().stringify({"session_token":session_token}))
	de.close()


func _on_button_start_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_button_score_pressed():
	pass # Replace with function body.

func _on_button_settings_pressed():
	pass # Replace with function body.

func _on_button_quit_pressed():
	get_tree().quit()






func _on_pseudo_input_gui_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == 4194309:
			pass
