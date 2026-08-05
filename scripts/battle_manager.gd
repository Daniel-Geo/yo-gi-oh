extends Node

@export var card_slot_scale: float = 0.8
@export var card_move_speed: float = 0.2

@onready var card_manager: Node2D = $"../CardManager"
@onready var end_turn_button: Button = $"../CanvasLayer/EndTurnButton"
@onready var player_deck: Node2D = $"../PlayerDeck"
@onready var opponent_deck: Node2D = $"../OpponentDeck"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var monster_card_slots: Node2D = $"../CardSlots/OpponentCardSlots/MonsterCardSlots"
@onready var opponent_hand = $"../OpponentHand"

var empty_monster_card_slots: Array

func _ready() -> void:
	for card_slot in monster_card_slots.get_children():
		empty_monster_card_slots.append(card_slot)

func opponent_turn() -> void:
	end_turn_button.disabled = true
	end_turn_button.visible = false
	
	if opponent_deck.opponent_deck.size() != 0:
		opponent_deck.draw_card()
		await wait_battle_timer()
	
	if empty_monster_card_slots.size() == 0:
		await wait_battle_timer()
		end_opponent_turn()
		return
	
	try_play_highest_attack_card()
	await wait_battle_timer()
	
	end_opponent_turn()

func wait_battle_timer() -> void:
	battle_timer.start()
	await battle_timer.timeout

func try_play_highest_attack_card() -> void:
	if opponent_hand.opponent_hand.size() == 0:
		end_opponent_turn()
		return
	
	var random_empty_monster_card_slot = empty_monster_card_slots[randi_range(0, empty_monster_card_slots.size() - 1)]
	empty_monster_card_slots.erase(random_empty_monster_card_slot)
	
	var highest_attack_card: Node2D = opponent_hand.opponent_hand[0]
	for card in opponent_hand.opponent_hand:
		if card.attack > highest_attack_card.attack:
			highest_attack_card = card
	
	var tween_position = get_tree().create_tween()
	tween_position.tween_property(highest_attack_card, "position", random_empty_monster_card_slot.position, card_move_speed)
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property(highest_attack_card, "scale", Vector2(card_slot_scale, card_slot_scale), card_move_speed)
	highest_attack_card.get_node("AnimationPlayer").play("card_flip")
	opponent_hand.remove_card_from_hand(highest_attack_card)

func end_opponent_turn() -> void:
	player_deck.has_drawn_card_this_turn = false
	card_manager.has_played_monster_card_this_turn = false
	end_turn_button.disabled = false
	end_turn_button.visible = true

func _on_end_turn_button_pressed() -> void:
	opponent_turn()
