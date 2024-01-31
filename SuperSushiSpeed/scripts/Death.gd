extends Control
var connectCurrent = HTTPRequest.new()
var submit_score_http =  HTTPRequest.new()
var get_score_http: HTTPRequest
var leaderboard_key = "20069"
var score : int
var combo : int
var API_KEY = "prod_4135c08094c1428cbe83647654cf6a81"
var session_token: String
var player_id: int
var player_name: String
var score_set: bool = false
var play_anim = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if play_anim == true:
		get_node("best/AnimationPlayer").play("wow")


func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/count_down.tscn")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func set_score(x,y,on_time,late,not_late,mist):
	if score_set == false:
		score = x
		combo = y
		get_node("combo").text = str(y)
		get_node("label_score").text = str(x)
		get_node("beatsmiss").text = str(mist+late+not_late)
		get_node("perfect").text = str(on_time)
		save_score()
		score_set = true
	
func save_score():
	var player_identifier = Global.player_identifier
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
	connectCurrent.request_completed.connect(get_seesion)

func get_seesion(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	session_token = json["session_token"]
	player_id = json["player_id"]
	player_name = json["player_name"]
	var header = ["x-session-token:" + session_token]
	get_score_http = HTTPRequest.new()
	add_child(get_score_http)
	get_score_http.request_completed.connect(score_getted)
	get_score_http.request(
		"https://api.lootlocker.io/game/leaderboards/"+str(leaderboard_key)+"/member/"+str(player_id),
		header,
		HTTPClient.METHOD_GET
		)

func score_getted(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	var last_score = json["score"]
	if last_score < score:
		get_node("best").set_visible(true)
		play_anim = true
		save()
	else:
		get_node("best").set_visible(false)

func save():	
	var data = { "score": str(score), "member_id":player_name, "matadata": combo}
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
