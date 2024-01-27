extends Control



var developpement_mode = true
var leaderboard_key = "super_sushi_speed_shazal_clef_loot_locker"
var leaderboard_id = 19889
var score = 10000
var submit_score_http
# HTTP Request node can only handle one call per node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_save_pressed():
	var de = FileAccess.open("res://usersave/session.txt", FileAccess.READ)
	var session = JSON.parse_string(de.get_as_text())
	var session_token = session["session_token"]
	var data = { "score": str(score), "member_id": "Andinox" }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	# Print what we're sending, for debugging purposes:
	print(data)


func _on_upload_score_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	# Print data
	print(json.get_data())
	submit_score_http.queue_free()

