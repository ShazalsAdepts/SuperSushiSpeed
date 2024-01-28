extends Control
var API_KEY = "prod_4135c08094c1428cbe83647654cf6a81"
var player_identifier: String
var connectCurrent = HTTPRequest.new()

var leaderboard_key = "19943"
var session_token: String = ""
var getsession: HTTPRequest
var leaderboard_http: HTTPRequest
var player_id: String

@export var settings: Control

func _ready():
	if FileAccess.file_exists("res://usersave/user_login.json"):
		print("file existe")
		var de = FileAccess.open("res://usersave/user_login.json", FileAccess.READ)
		var data = JSON.parse_string(de.get_as_text())
		de.close()
		var popup = get_node("../Panel")
		var pseudo = get_node("Pseudo")
		if data["player_identifier"] == null ||  data["player_identifier"] == "":
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
			add_child(connectCurrent)
			connectCurrent.request(
				"https://api.lootlocker.io/game/v2/session/guest",
				hearders,
				HTTPClient.METHOD_POST,
				game
			)
			connectCurrent.request_completed.connect(_on_request_completed)
	else:
		print("not exist")
		var de = FileAccess.open("res://usersave/user_login.json", FileAccess.WRITE)
		de.store_string(JSON.new().stringify({"player_identifier":null}))
		de.close()
		var popup = get_node("../Panel")
		popup.set_visible(true)
		
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	session_token = json["session_token"]
	var pseudo = json["player_name"]
	player_id = str(json["player_id"])
	get_node("Pseudo").text = pseudo
	connectCurrent.queue_free()

func load_session():
	var de = FileAccess.open("res://usersave/user_login.json", FileAccess.READ)
	var data = JSON.parse_string(de.get_as_text())
	de.close()
	player_identifier = data["player_identifier"]
	var hearders = PackedStringArray(["Content-Type: application/json"])
	var game = JSON.new().stringify({
		"game_key" : API_KEY,
		"player_identifier": player_identifier,
		"game_version": "0.1.0"
	})
	getsession = HTTPRequest.new()
	add_child(getsession)
	getsession.request(
		"https://api.lootlocker.io/game/v2/session/guest",
		hearders,
		HTTPClient.METHOD_POST,
		game
	)
	getsession.request_completed.connect(_on_load_completed)
	
func _on_load_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	session_token = json["session_token"]
	player_id = str(json["player_id"])
	connectCurrent.queue_free()
	
func _on_button_start_pressed():
	SceneTransition.change_scene("res://scenes/count_down.tscn", 'dissolve')

func _on_button_score_pressed():
	get_node("HowToPlay").set_visible(false)
	get_node("LeaderBoard").set_visible(true)
	var getlearder = get_node("LeaderBoard/RichTextLabel");
	if session_token == "":
		load_session()
	else:
		get_leaderboards()

func _on_button_settings_pressed():
	self.set_visible(false)
	settings.set_visible(true)

func _on_button_quit_pressed():
	get_tree().quit()

func get_leaderboards():
	print("Getting leaderboards")
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	
	# Send request
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")

func _on_leaderboard_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	# Formatting as a leaderboard
	var player = "You: "
	var leaderboardFormatted = ""
	for n in json.get_data().items.size():
		leaderboardFormatted += str(json.get_data().items[n].rank)+str(". ")
		leaderboardFormatted += str(json.get_data().items[n].player.name)+str(" - ")
		leaderboardFormatted += str(json.get_data().items[n].score)+str("\n")
		if (str(json.get_data().items[n].player.id) == player_id):
			player += str(json.get_data().items[n].rank)+str(". ")
			player += str(json.get_data().items[n].player.name)+str(" - ")
			player += str(json.get_data().items[n].score)
	get_node("LeaderBoard/RichTextLabel").text = leaderboardFormatted
	get_node("LeaderBoard/score").text = player
	# Clear node
	leaderboard_http.queue_free()

func _on_pseudo_input_gui_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == 4194309:
			pass

func _on_close_pressed():
	get_node("LeaderBoard").set_visible(false)

func _on_button_credits_pressed():
	get_node("HowToPlay").set_visible(true)
	get_node("LeaderBoard").set_visible(false)

func _on_close_htplay_pressed():
	get_node("HowToPlay").set_visible(false)
