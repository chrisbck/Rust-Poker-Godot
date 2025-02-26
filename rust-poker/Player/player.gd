extends Node2D
class_name Player

enum PlayerState{
	WAITING,
	THINKING,
	FOLDED,
	CALLED,
	RAISED,
	ALL_IN,
	SITTING_OUT,
	DISCONNECTED,
	OUT,
	WINNER	
}

var id: String
var table_position: int
var avatar_path: String
var action_timer_duration: int
var state: PlayerState:
	get: return state
	set(value):
		state = value
		update_status_label()
		
var display_name: String:
	get: return display_name
	set(value):
		display_name = value
		$NameLabel.text = value 

var chips: int:
	get:return chips
	set(value):
		chips = max(value, 0)	# ensure chips does not go below zero
		set_bet_stack(value)
		$StackLabel.text = str(chips)

# Booleans
@onready var is_turn: bool = false
@onready var is_active: bool = false
@onready var is_sitting_out: bool = false

# Objects
@onready var bet_stack: Stack = $BetStack


func _ready():
	self.visible = false


func intialise(id: String, display_name: String, starting_stack: int, table_position) -> void:
	self.id = id
	self.table_position = table_position
	self.display_name = display_name
	self.chips = starting_stack

func initialise_from_JSON(player_data: Dictionary) -> void:
	id = player_data.get("id", "")
	table_position = player_data.get("table_position", 0)
	display_name = player_data.get("display_name", "Unknown")
	chips = player_data.get("chips", 0)
	action_timer_duration = player_data.get("action_timer", 0.0)
	is_active = player_data.get("is_active", true)
	var backend_state = player_data.get("state", "Waiting")
	enumarate_backend_state(backend_state)
	
	
func enumarate_backend_state(backend_state: String):
	match backend_state:
		"Waiting": state = PlayerState.WAITING
		"Thinking": state = PlayerState.THINKING
		"Folded": state = PlayerState.FOLDED
		"Called": state = PlayerState.CALLED
		"Raised": state = PlayerState.RAISED
		"All-In": state = PlayerState.ALL_IN
		"Sitting Out": state = PlayerState.SITTING_OUT
		"Disconnected": state = PlayerState.DISCONNECTED
		"Out": state = PlayerState.OUT
		"Winner": state = PlayerState.WINNER
		_: 
			print("Unknown state:", backend_state)
			state = PlayerState.WAITING # Default fallback
	
	
func update_UI() -> void:
	self.visible = is_active
	$NameLabel.text = display_name
	
func update_status_label() -> void:
	match state:
		PlayerState.WAITING:
			$StatusLabel.text = "Waiting"
			$StatusLabel.modulate = Color.WHITE
		PlayerState.THINKING:
			$StatusLabel.text = "Thinking..."
			$StatusLabel.modulate = Color.GREEN
		PlayerState.FOLDED:
			$StatusLabel.text = "Folded"
			$StatusLabel.modulate = Color.GRAY
		PlayerState.CALLED:
			$StatusLabel.text = "Called"
			$StatusLabel.modulate = Color.BLUE
		PlayerState.RAISED:
			$StatusLabel.text = "Raised"
			$StatusLabel.modulate = Color.ORANGE
		PlayerState.ALL_IN:
			$StatusLabel.text = "ALL IN!"
			$StatusLabel.modulate = Color.RED
			#$StateLabel.set("theme_override_font", preload("res://fonts/bold_font.tres"))
		PlayerState.SITTING_OUT:
			$StatusLabel.text = "Sitting Out"
			$StatusLabel.modulate = Color.GRAY
		PlayerState.DISCONNECTED:
			$StatusLabel.text = "Disconnected"
			$StatusLabel.modulate = Color.RED
			#start_blinking()
		PlayerState.OUT:
			$StatusLabel.text = "Out"
			$StatusLabel.modulate = Color.BLACK
		PlayerState.WINNER:
			$StatusLabel.text = "Winner!"
			$StatusLabel.modulate = Color.GOLD
	pass
	
func set_bet_stack(is_active: bool, amount: int = 0) -> void:
	bet_stack.set_amount(is_active, amount)

func is_round_winner():
	# Do winning display / animation
	pass

func return_puck_position() -> Vector2:
	return $PuckPosition.global_position

# ------------- Signals
func _on_action_timer_timeout():
	# hide UI buttons.
	pass # Replace with function body.

func reset() -> void:
	id = ""
	display_name = ""
	chips = 0
	state = PlayerState.WAITING
	#hole_cards.clear()			[TODO] implement clear function
	is_turn = false
	is_active = false
	avatar_path = ""		#[TODO] set a default avatar

	# Clear UI
	$NameLabel.text = "Empty Seat"
	chips = 0

	self.visible = false
