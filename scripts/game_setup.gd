extends Node2D

@export var starting_health: int = 10

@onready var player_health: RichTextLabel = %PlayerHealth
@onready var opponent_health: RichTextLabel = $OpponentField/%OpponentHealth
@onready var battle_manager: Node = $BattleManager
@onready var player_deck: Node2D = $PlayerDeck
@onready var opponent_deck: Node2D = $OpponentField/%OpponentDeck
@onready var end_turn_button: Button = $CanvasLayer/MarginContainer/EndTurnButton
@onready var input_manager: Node2D = $InputManager


func host_setup() -> void:
	player_health.text = str(starting_health)
	get_parent().get_node("OpponentField/CanvasLayer/MarginContainer/OpponentHealth").text = str(starting_health)
	battle_manager.player_health = starting_health
	battle_manager.opponent_health = starting_health
	get_parent().get_node("OpponentField/OpponentDeck").deck_size = get_parent().get_node("OpponentField/OpponentDeck").opponent_deck.size()
	get_parent().get_node("OpponentField/OpponentDeck/RichTextLabel").text = str(get_parent().get_node("OpponentField/OpponentDeck").opponent_deck.size())
	await player_deck.draw_initial_hand()
	end_turn_button.disabled = false
	end_turn_button.visible = true
	input_manager.input_disabled = false

func client_setup() -> void:
	player_health.text = str(starting_health)
	get_parent().get_node("OpponentField/CanvasLayer/MarginContainer/OpponentHealth").text = str(starting_health)
	battle_manager.player_health = starting_health
	battle_manager.opponent_health = starting_health
	player_deck.draw_initial_hand()
