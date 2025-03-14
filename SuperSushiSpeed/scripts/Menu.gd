extends Control
var API_KEY = "prod_4135c08094c1428cbe83647654cf6a81"
var player_identifier: String
var connectCurrent = HTTPRequest.new()

var leaderboard_key = "20069"
var session_token: String = ""
var getsession: HTTPRequest
var leaderboard_http: HTTPRequest
var player_id: String

@onready var fumee = $"../background/Terrain_1/RectangleStanding_4/GPUParticles3D"
@export var settings: Control

#var config_path = "user://usersave/config.cfg"
#@onready var config = ConfigFile.new()

func _ready():
	if Global.player_identifier != null:
		#print("file existe")
		#var de = FileAccess.open("res://usersave/user_login.json", FileAccess.READ)
		#var data = JSON.parse_string(de.get_as_text())
		#de.close()
		var popup = get_node("../Panel")
		var pseudo = get_node("Pseudo")
		if 1 == 2:
			popup.set_visible(true)
		else:
			popup.set_visible(false)
			pseudo.set_visible(true)
			get_node("deco").set_visible(true)
			player_identifier = Global.player_identifier
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
		var popup = get_node("../Panel")
		popup.set_visible(true)
		#var de = FileAccess.open("res://usersave/user_login.json", FileAccess.WRITE)
		#de.store_string(JSON.new().stringify({"player_identifier":null}))
		#de.close()
		
	
	fumee.emitting = false
	
	#var err = config.load(config_path)
	#var test_number = 0
	#while test_number < 5 and err != OK:
	#	init_config()
	#	err = config.load(config_path)
	#	test_number += 1
	#	
	#if err == OK:
	#	load_config()

#func load_config():
	#var bus_sfx = AudioServer.get_bus_index("SFX")
	#var bus_music = AudioServer.get_bus_index("Music")
	#Global.ping = config.get_value("PING","ping")
	#var value_sfx = config.get_value("AUDIO","sfx")
	#var value_music = config.get_value("AUDIO","music")
	#
	#if value_sfx > -24:
	#	AudioServer.set_bus_mute(bus_sfx, false)
	#	AudioServer.set_bus_volume_db(bus_sfx, value_sfx)
	#else:
	#	AudioServer.set_bus_mute(bus_sfx, true)
	#	
	#if value_music > -24:
	#	AudioServer.set_bus_mute(bus_music, false)
	#	AudioServer.set_bus_volume_db(bus_music, value_music)
	#else:
	#	AudioServer.set_bus_mute(bus_music, true)
	#	
	#var window_size = ["Widowed", "FullScreen", "Borderless"]
	#var index = config.get_value("VIDEO","screen_id")
	#if window_size[index] == "Widowed":
	#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	#elif window_size[index] == "FullScreen":
	#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	#elif window_size[index] == "Borderless":
	#	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

#func init_config():
	#config.set_value("VIDEO", "screen_id", 0)
	#config.set_value("AUDIO", "music", 0)
	#config.set_value("AUDIO", "sfx", 0)
	#config.set_value("PING", "ping", 0)
	#config.save(config_path)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	session_token = json["session_token"]
	var pseudo = json["player_name"]
	player_id = str(json["player_id"])
	get_node("Pseudo").text = pseudo
	connectCurrent.queue_free()

func load_session():
	player_identifier = Global.player_identifier
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
	SceneTransition.change_scene("scenes/count_down.tscn", 'dissolve')

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
	var player = "You : "
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

func _on_deco_pressed():
	Global.player_identifier = null
	get_node("deco").set_visible(false)
	get_node("Pseudo").set_visible(false)
	get_node("../Panel").set_visible(true)
