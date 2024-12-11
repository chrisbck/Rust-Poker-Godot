extends Node

@onready var card_1 = $HoleCard1
@onready var card_2 = $HoleCard2
@onready var http_request = $HTTPRequest
@onready var hole_button = $HoleButton

const SERVER_URL = "http://127.0.0.1:3030"  # Replace with your server's URL

func _ready():
	pass


func _on_hole_button_pressed():
	# Send a request to deal 2 cards
	var url = SERVER_URL + "/deal?count=2"
	http_request.request(url)


func _on_http_request_request_completed(result, response_code, headers, body):
	print("HTTP response received. Code:", response_code)
	if response_code == 200:
		var json_parser = JSON.new()  # Create an instance of the JSON class
		var parse_result = json_parser.parse(body.get_string_from_utf8())

		if parse_result == OK:
			var response_data = json_parser.get_data()
			print("Response:", response_data)
			
			# Handle "Deck has been reset" response (String)
			if typeof(response_data) == TYPE_STRING and response_data == "Deck has been reset":
				print("Deck reset successfully!")
				# Optionally reset card visuals
				card_1.animated_sprite.frame = 0
				card_2.animated_sprite.frame = 0
				
			# Handle dealt cards response (Array)	
			elif typeof(response_data) == TYPE_ARRAY and response_data.size() == 2:
				# Handle deal response
				card_1.set_card_from_json(response_data[0])
				card_2.set_card_from_json(response_data[1])
			else:
				print("Unexpected response format:", response_data)
		else:
			print("Failed to parse JSON. Error code:", parse_result)
	else:
		print("Failed to fetch data. Response code:", response_code)


func _on_reset_button_pressed():
	var url = SERVER_URL + "/reset"
	http_request.request(url)
