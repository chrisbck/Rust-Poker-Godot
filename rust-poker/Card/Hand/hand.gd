extends Node2D

@onready var card_nodes = get_children()

# Updates the cards in the hand based on the best hand JSON
func update_hand_from_json(card_data_list: Array):

	for i in range(len(card_data_list)):
		if i < len(card_nodes) and card_nodes[i].has_method("set_card_from_json"):
			card_nodes[i].set_card_from_json(card_data_list[i])
		else:
			print("Invalid card data or missing method for node at index %d" % i)


func reset_hand() -> void:
	for card in card_nodes:
		card.show_back()
