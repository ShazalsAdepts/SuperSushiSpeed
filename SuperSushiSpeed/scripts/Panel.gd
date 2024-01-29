extends Panel
var GAME_KEY = "prod_4135c08094c1428cbe83647654cf6a81"
var pseudo = "newbie"
@export var session_token: String
@export var player_identifier: String
var leaderboard_id = 20069
var saveRequest = HTTPRequest.new()
var rename = HTTPRequest.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var pseudoInput = get_node("TextEdit")
	pseudo = pseudoInput.text
	
	var hearders = PackedStringArray(["Content-Type: application/json"])
	var data = JSON.new().stringify({
		"game_key": GAME_KEY,
		"game_version": "0.1.0"
	})
	add_child(saveRequest)
	saveRequest.request(
		"https://api.lootlocker.io/game/v2/session/guest",
		hearders,
		HTTPClient.METHOD_POST,
		data
	)
	saveRequest.request_completed.connect(_on_request_completed)
	
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	saveRequest.queue_free()
	session_token = json["session_token"]
	player_identifier = json["player_identifier"]
	var url = "https://api.lootlocker.io/game/player/name"
	var header = [
		"x-session-token: "+ session_token,
		"LL-Version: 2021-03-01",
		"Content-Type: application/json"
	]

	add_child(rename)
	rename.request_completed.connect(on_rename_completed)
	rename.request(url,header,HTTPClient.METHOD_PATCH, JSON.new().stringify({"name": pseudo}))
	
	
	
func on_rename_completed(result, response_code, headers, body):
	var pseudot = get_node("../Control/Pseudo")
	pseudot.text = pseudo
	pseudot.set_visible(true)
	rename.queue_free()
	var de = FileAccess.open("res://usersave/user_login.json", FileAccess.WRITE)
	de.store_string(JSON.new().stringify({"player_identifier":player_identifier}))
	get_node(".").set_visible(false)
	get_node("../Control/deco").set_visible(true)
