extends Node

@onready var http_request = $HTTPRequest
@onready var community_cards = $CommunityCards  # Container holding community Card nodes
@onready var hole_cards = $HoleCards           # Container holding hole Card nodes
@onready var evaluation_label = $Diagnostics/EvaluationLabel

# Called when the node enters the scene tree for the first time
func _ready():
	evaluation_label.text = "Ready to Play!"

# Sends a request to deal hole cards
func _on_HoleButton_pressed():
	print("Requesting hole cards...")
	var error = http_request.request("http://127.0.0.1:3030/deal_hole")
	if error != OK:
		print("HTTPRequest error: ", error)

# Sends a request to deal community cards
func _on_CommunityButton_pressed():
	print("Requesting community cards...")
	var error = http_request.request("http://127.0.0.1:3030/deal_community")
	if error != OK:
		print("HTTPRequest error: ", error)

# Sends a request to reset the game state
func _on_ResetButton_pressed():
	print("Resetting game state...")
	var error = http_request.request("http://127.0.0.1:3030/reset")
	if error == OK:
		reset_all_cards()
		evaluation_label.text = "Game Reset"
	else:
		print("HTTPRequest error: ", error)

# Handles HTTP request completion and processes the response
func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	print("Request completed. Response code: ", response_code)

	if response_code == 200:
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(body.get_string_from_utf8())
		if parse_result == OK:
			var data = json_parser.get_data()

			# Extract cards and request type
			var cards = data.get("cards", [])
			var request_type = data.get("type", "")

			if request_type == "hole":
				print("Hole cards received: ", cards)
				update_hole_cards(cards)  # Update hole cards
			elif request_type == "community":
				print("Community cards received: ", cards)
				update_community_cards(cards)  # Update community cards
			elif request_type == "evaluation":
				var best_hand = data.get("rank", null)
				print("Evaluation received")
				update_besthand(best_hand)
			else:
				print("Unknown request type: ", request_type)
		else:
			print("Failed to parse JSON. Error code: ", parse_result)
	else:
		print("Request failed with response code: ", response_code)

# Updates the card sprites with JSON data
func update_card_sprites(card_sprites, card_data):
	for i in range(len(card_data)):
		if i < len(card_sprites):
			var card = card_data[i]
			card_sprites[i].set_card_from_json(card)

# Updates the community cards
func update_community_cards(card_data):
	var card_sprites = community_cards.get_children()
	update_card_sprites(card_sprites, card_data)
	
	var error = http_request.request("http://127.0.0.1:3030/evaluate")
	if error != OK:
		print("HTTPRequest error: ", error)
		
# Updates the hole cards
func update_hole_cards(card_data):
	var card_sprites = hole_cards.get_children()
	update_card_sprites(card_sprites, card_data)

func update_besthand(best_hand):
	evaluation_label.text = "Best hand: " + best_hand
	
# Resets all card sprites to their default state
func reset_all_cards():
	var all_cards = community_cards.get_children() + hole_cards.get_children()
	for card in all_cards:
		card.set_card_from_json({"rank":"Two","suit":"Spades"})  # Reset to empty or default state
