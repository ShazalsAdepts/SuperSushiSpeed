extends Control
var connectCurrent = HTTPRequest.new()
var submit_score_http =  HTTPRequest.new()
var leaderboard_key = "19943"
var score : int
var API_KEY = "prod_4135c08094c1428cbe83647654cf6a81"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func set_score(x):
	score = x
	$MarginContainer/VBoxContainer/label_score.text = "  Score: " + str(x)


func _on_save_pressed():
	var de = FileAccess.open("res://usersave/user_login.json", FileAccess.READ)
	var data = JSON.parse_string(de.get_as_text())
	de.close()
	var player_identifier = data["player_identifier"]
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

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var session_token = json["session_token"]
	var player_id = json["player_id"]
	var player_name = json["player_name"]
	var data = { "score": str(score), "member_id":player_name, "matadata": player_id}
	var header = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", header, HTTPClient.METHOD_POST, JSON.stringify(data))



func _on_upload_score_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	print("score update")
	# Print data
	print(json.get_data())
	submit_score_http.queue_free()
