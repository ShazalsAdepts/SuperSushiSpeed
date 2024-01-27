extends Control
var submit_score_http: HTTPRequest
var leaderboard_key = "19889"
var score : int
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
	var de = FileAccess.open("res://usersave/session.json", FileAccess.READ)
	var session = JSON.parse_string(de.get_as_text())
	var session_token = session["session_token"]
	var data = { "score": str(score), "member_id": "Andinox" }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))



func _on_upload_score_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	print("score update")
	# Print data
	print(json.get_data())
	submit_score_http.queue_free()
