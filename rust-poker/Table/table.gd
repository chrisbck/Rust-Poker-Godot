extends Node

@onready var http_request = $HTTPRequest
@onready var community_cards = $CommunityCards  # Container holding community Card nodes
@onready var evaluation_label = $Diagnostics/EvaluationLabel
@onready var players = $Players  # Container holding all player nodes

# Called when the node enters the scene tree for the first time
func _ready():
	evaluation_label.text = "Ready to Play!"

# Sends a request to deal hole cards for all players
func _on_HoleButton_pressed():
	print("Requesting hole cards for all players...")
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
			var request_type = data.get("type", "")

			if request_type == "hole":
				print("Hole cards received.")
				update_player_hole_cards(data.get("players", []))  # Update hole cards for all players
			elif request_type == "community":
				print("Community cards received.")
				update_community_cards(data.get("cards", []))  # Update community cards
			elif request_type == "evaluation":
				var best_hand_label = data.get("rank", null)
				var best_cards = data.get("cards", null)
				
				print("Evaluation received.")
				#update_besthand_label(best_hand_label)
				#update_besthand_cards(best_cards)
			elif request_type == "test_winners":
				print("Test Winners received.")
				display_winners(data.get("players", []))  # Update UI with winners
				update_besthand_cards(data.get("players", [])[0].get("best_hand", []))
			elif request_type == "reset":
				reset_all_cards()
			else:
				print("Unknown request type: ", request_type)
		else:
			print("Failed to parse JSON. Error code: ", parse_result)
	else:
		print("Request failed with response code: ", response_code)

# Updates hole cards for all players
func update_player_hole_cards(players_data: Array):
	var player_nodes = players.get_children()

	for i in range(len(players_data)):
		if i < len(player_nodes):
			var player_data = players_data[i]
			var hole_cards_data = player_data.get("hole_cards", [])
			var player_name = player_data.get("name", "Unknown")
			print("Updating cards for player: ", player_name)

			var hole_cards = player_nodes[i].get_children()  # Get HoleCard1 and HoleCard2 nodes
			
			for j in range(len(hole_cards_data)):
				if j < len(hole_cards) and hole_cards[j].has_method("set_card_from_json"):
					hole_cards[j].set_card_from_json(hole_cards_data[j])
				else:
					print("Invalid card or missing method for player ", player_name, ", card ", j)

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
	
	var error = http_request.request("http://127.0.0.1:3030/test_winners")
	if error != OK:
		print("HTTPRequest error: ", error)
		
func update_besthand_label(best_hand):
	evaluation_label.text = "Best hand: " + best_hand

func update_besthand_cards(cards):
	$BestHand.update_hand_from_json(cards)
	
func update_remaining_cards(remaining: int) -> void:
	$Diagnostics/RemainingCards.text = "Remaining Cards: " + str(remaining)

func display_winners(winners_data: Array):
	print(winners_data)
	pass

# Resets all card sprites to their default state
func reset_all_cards():
	var all_cards = community_cards.get_children()
	
	# Add all hole cards from players
	for player in players.get_children():
		all_cards += player.get_children()

	for card in all_cards:
		if card.has_method("show_back"):
			card.show_back()
	
	$BestHand.reset_hand()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
