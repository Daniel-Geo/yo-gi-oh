extends Node2D

@export var hand_count: int = 8
@export var card_width: float = 35
@export var player_hand_y_position: float = 100

@onready var card_manager: Node2D = $"../CardManager"
@onready var camera_2d: Camera2D = $"../Camera2D"

var player_hand: Array = []
var center_screen_x: float

func _ready() -> void:
	var card_scene = preload("res://scenes/card.tscn")
	for i in range(hand_count):
		var new_card = card_scene.instantiate()
		card_manager.add_child(new_card)
		new_card.name = "Card"
		add_card_to_hand(new_card)
		

func add_card_to_hand(card) -> void:
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.starting_position)


func update_hand_positions() -> void:
	for i in range(player_hand.size()):
		var new_position = Vector2(calculate_card_position(i), player_hand_y_position)
		var card = player_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position)

func calculate_card_position(index) -> float:
	var total_width = (player_hand.size() - 1) * card_width
	var x_offset = index * card_width - total_width / 2
	return x_offset

func animate_card_to_position(card, new_position) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, 0.2)

func remove_card_from_hand(card) -> void:
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.starting_position)
