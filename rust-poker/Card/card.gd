extends Node2D

enum CardSuit {CLUBS = 0, HEARTS = 1, SPADES = 2, DIAMONDS = 3}
enum CardRank {TWO = 0, THREE = 1, FOUR = 2, FIVE = 3, SIX = 4, SEVEN = 5, EIGHT = 6, NINE = 7, TEN = 8, JACK = 9, QUEEN = 10, KING = 11, ACE = 12}

const RANK_MAP = {
	"Two": CardRank.TWO,
	"Three": CardRank.THREE,
	"Four": CardRank.FOUR,
	"Five": CardRank.FIVE,
	"Six": CardRank.SIX,
	"Seven": CardRank.SEVEN,
	"Eight": CardRank.EIGHT,
	"Nine": CardRank.NINE,
	"Ten": CardRank.TEN,
	"Jack": CardRank.JACK,
	"Queen": CardRank.QUEEN,
	"King": CardRank.KING,
	"Ace": CardRank.ACE
}

const SUIT_MAP = {
	"Hearts": CardSuit.HEARTS,
	"Diamonds": CardSuit.DIAMONDS,
	"Clubs": CardSuit.CLUBS,
	"Spades": CardSuit.SPADES
}

const NUM_RANKS = 13

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func calculate_sprite_frame(rank: int, suit: int) -> int:
	return suit * NUM_RANKS + rank
	
# Function to set the card based on JSON data
func set_card_from_json(card_data: Dictionary):
	var rank = RANK_MAP.get(card_data.get("rank", ""), null)
	var suit = SUIT_MAP.get(card_data.get("suit", ""), null)

	if rank != null and suit != null:
		var frame_index = calculate_sprite_frame(rank, suit)
		animated_sprite.frame = frame_index
	else:
		print("Invalid card data:", card_data)

func set_rank(rank: String) -> void:
	pass
	
func set_suit(suit: String) -> void:
	pass
