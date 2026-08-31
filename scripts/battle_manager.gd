extends Node

@export var player_health: int = 10
@export var opponent_health: int = 10
@export var card_slot_scale: float = 0.8
@export var card_move_speed: float = 0.2
@export var battle_position_offset: float = 25.0

@onready var input_manager: Node2D = $"../InputManager"
@onready var card_manager: Node2D = $"../CardManager"
@onready var end_turn_button: Button = $"../CanvasLayer/MarginContainer/EndTurnButton"
@onready var player_deck: Node2D = $"../PlayerDeck"
@onready var opponent_deck: Node2D = $"../OpponentDeck"
@onready var battle_timer: Timer = $"../BattleTimer"
@onready var monster_card_slots: Node2D = $"../CardSlots/OpponentCardSlots/MonsterCardSlots"
@onready var opponent_hand = $"../OpponentHand"
@onready var player_health_label: RichTextLabel = $"../CanvasLayer/MarginContainer/PlayerHealth"
@onready var opponent_health_label: RichTextLabel = $"../CanvasLayer/MarginContainer/OpponentHealth"
@onready var player_graveyard: Node2D = $"../PlayerGraveyard"
@onready var opponent_graveyard: Node2D = $"../OpponentGraveyard"
@onready var end_screen: Control = $"../CanvasLayer/EndScreen"

var is_player_turn: bool = true

var empty_monster_card_slots: Array
var player_cards_on_battlefield: Array
var opponent_cards_on_battlefield: Array
var player_cards_attacked_this_turn: Array

func _ready() -> void:
	player_health_label.text = str(player_health)
	opponent_health_label.text = str(opponent_health)
	for card_slot in monster_card_slots.get_children():
		empty_monster_card_slots.append(card_slot)

func opponent_turn() -> void:
	input_manager.input_disabled = true
	enable_end_turn_button(false)
	
	if opponent_deck.opponent_deck.size() != 0:
		opponent_deck.draw_card()
		await wait(1)
	
	if empty_monster_card_slots.size() != 0:
		try_play_highest_attack_card()
		await wait(1)
	
	if opponent_cards_on_battlefield.size() != 0:
		var enemy_cards_to_attack: Array = opponent_cards_on_battlefield.duplicate()
		for card in enemy_cards_to_attack:
			if player_cards_on_battlefield.size() == 0:
				await direct_attack(card, "opponent")
			else:
				var card_to_attack = player_cards_on_battlefield.pick_random()
				await attack(card, card_to_attack, "opponent")
	if player_health == 0:
		end_screen.show_end_screen("lost")
		return
	elif opponent_health == 0:
		end_screen.show_end_screen("win")
		return
	end_opponent_turn()

func wait(wait_time) -> void:
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout

func direct_attack(attacking_card, attacker) -> void:
	var new_pos_y: int
	if attacker == "opponent":
		new_pos_y = 120
		player_health = max(0, player_health - attacking_card.attack)
		player_health_label.text = str(player_health)
	else:
		input_manager.input_disabled = true
		enable_end_turn_button(false)
		new_pos_y = -120
		opponent_health = max(0, opponent_health - attacking_card.attack)
		opponent_health_label.text = str(opponent_health)
		player_cards_attacked_this_turn.append(attacking_card)
	var new_pos = Vector2(attacking_card.position.x, new_pos_y)
	attacking_card.z_index = 2
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, card_move_speed)
	await wait(0.15)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, card_move_speed)
	attacking_card.z_index = 0
	await wait(1)
	
	if player_health == 0:
		end_screen.show_end_screen("lost")
		return
	elif opponent_health == 0:
		end_screen.show_end_screen("win")
		return
	
	if attacker == "player":
		if attacking_card.ability_script:
			await attacking_card.ability_script.trigger_ability(self, input_manager, attacking_card, "card_attacked")
		input_manager.input_disabled = false
		enable_end_turn_button(true)

func attack(attacking_card, defending_card, attacker) -> void:
	if attacker == "player":
		card_manager.selected_monster = null
		input_manager.input_disabled = true
		enable_end_turn_button(false)
		player_cards_attacked_this_turn.append(attacking_card)
	attacking_card.z_index = 2
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + battle_position_offset)
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, card_move_speed)
	await wait(0.15)
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, card_move_speed)
	
	defending_card.health = max(0, defending_card.health - attacking_card.attack)
	defending_card.get_node("%Health").text = str(defending_card.health)
	attacking_card.health = max(0, attacking_card.health - defending_card.attack)
	attacking_card.get_node("%Health").text = str(attacking_card.health)
	await wait(1)
	attacking_card.z_index = 0
	
	var card_was_destroyed = false
	if attacking_card.health == 0:
		destroy_card(attacking_card, attacker)
	if defending_card.health == 0:
		card_was_destroyed = true
		if attacker == "player":
			destroy_card(defending_card, "opponent")
		else:
			destroy_card(defending_card, "player")
	
	if card_was_destroyed:
		await wait(1)
	
	if attacker == "player":
		if attacking_card.ability_script:
			await attacking_card.ability_script.trigger_ability(self, input_manager, attacking_card, "card_attacked")
		input_manager.input_disabled = false
		enable_end_turn_button(true)


func destroy_card(card, card_owner) -> void:
	var new_pos: Vector2
	if card_owner == "player":
		card.defeated = true
		card.get_node("Area2D/CollisionShape2D").disabled = true
		new_pos = player_graveyard.position
		player_cards_on_battlefield.erase(card)
		card.card_slot_card_is_in.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		new_pos = opponent_graveyard.position
		opponent_cards_on_battlefield.erase(card)
	
	card.card_slot_card_is_in.is_card_in_card_slot = false
	card.card_slot_card_is_in = null
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, card_move_speed)
	card.z_index = -1

func opponent_card_selected(defending_card):
	var attacking_card = card_manager.selected_monster
	if attacking_card and defending_card in opponent_cards_on_battlefield:
		attack(attacking_card, defending_card, "player")

func try_play_highest_attack_card() -> void:
	if opponent_hand.opponent_hand.size() == 0:
		end_opponent_turn()
		return
	
	var random_empty_monster_card_slot = empty_monster_card_slots.pick_random()
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
	highest_attack_card.card_slot_card_is_in = random_empty_monster_card_slot
	opponent_hand.remove_card_from_hand(highest_attack_card)
	opponent_cards_on_battlefield.append(highest_attack_card)

func end_opponent_turn() -> void:
	is_player_turn = true
	player_deck.has_drawn_card_this_turn = false
	card_manager.has_played_monster_card_this_turn = false
	input_manager.input_disabled = false
	enable_end_turn_button(true)

func _on_end_turn_button_pressed() -> void:
	is_player_turn = false
	for card in player_cards_attacked_this_turn:
		if card.ability_script:
			card.ability_script.reset_ability()
	card_manager.unselect_monster()
	player_cards_attacked_this_turn.clear()
	opponent_turn()

func enable_end_turn_button(is_enabled: bool) -> void:
	end_turn_button.disabled = not is_enabled
	end_turn_button.visible = is_enabled
