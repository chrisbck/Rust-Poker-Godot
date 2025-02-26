extends Node2D

@onready var players = $Players.get_children()  # Get all pre-instanced Player nodes
@onready var max_players: int = players.size()  # Dynamically get max players


var test_json = """
{
  "players": [
	{
	  "id": "p1",
	  "table_position": 0,
	  "display_name": "Alice",
	  "chips": 1000,
	  "state": "Waiting",
	  "avatar_id": "avatar_1",
	  "action_timer": 30
	},
	{
	  "id": "p2",
	  "table_position": 1,
	  "display_name": "Bob",
	  "chips": 900,
	  "state": "Thinking",
	  "avatar_id": "avatar_2",
	  "action_timer": 25
	},
	{
	  "id": "p3",
	  "table_position": 4,
	  "display_name": "Charlie",
	  "chips": 1500,
	  "state": "All-In",
	  "avatar_id": "avatar_3",
	  "action_timer": 20
	}
  ]
}
"""


func _ready():
	print("Testing BaseTable population...")
	populate_table_from_JSON(test_json)
	set_bet_stack(false)
	
	

func set_bet_stack(is_visible: bool, amount: int = 0) -> void:
	for player: Player in $Players.get_children():
		player.set_bet_stack(is_visible)


# Function to populate the table with multiple players
func populate_table_from_JSON(json_string: String):
	var json_data = JSON.parse_string(json_string)

	if json_data == null or not json_data.has("players"):
		print("Error: Invalid JSON data.")
		return

	# Reset all player slots before assigning new data
	for player in players:
		player.reset()

	# Assign each player using add_player_from_JSON
	for player_data in json_data["players"]:
		add_player_from_JSON(player_data)


# Function to add a single player from JSON
func add_player_from_JSON(player_data: Dictionary):
	if not player_data.has("table_position"):
		print("Error: Missing table_position in player JSON")
		return

	var seat: int = player_data["table_position"]  # Get the seat position

	if seat < 0 or seat >= players.size():
		print("Error: Invalid seat position:", seat)
		return

	var player_instance = players[seat]

	if player_instance.is_active:
		print("Warning: Seat", seat, "is already occupied by", player_instance.display_name)
		return

	player_instance.initialise_from_JSON(player_data)
	player_instance.visible = player_instance.is_active  # Make visible if active
	print("Player", player_instance.display_name, "added to seat", seat)
