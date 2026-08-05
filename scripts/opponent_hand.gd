extends Node2D

@export var card_width: float = 35
@export var opponent_hand_y_position: float = -112

@onready var card_manager: Node2D = $"../CardManager"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var card_draw_speed: float = $"../PlayerDeck".card_draw_speed

var opponent_hand: Array = []
var center_screen_x: float


func add_card_to_hand(card, speed) -> void:
	if card not in opponent_hand:
		opponent_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.starting_position, speed)


func update_hand_positions(speed) -> void:
	for i in range(opponent_hand.size()):
		var new_position = Vector2(calculate_card_position(i), opponent_hand_y_position)
		var card = opponent_hand[i]
		card.starting_position = new_position
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index) -> float:
	var total_width = (opponent_hand.size() - 1) * card_width
	var x_offset = -index * card_width + total_width / 2
	return x_offset

func animate_card_to_position(card, new_position, speed) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card) -> void:
	if card in opponent_hand:
		opponent_hand.erase(card)
		update_hand_positions(card_draw_speed)
	else:
		animate_card_to_position(card, card.starting_position, card_draw_speed)
