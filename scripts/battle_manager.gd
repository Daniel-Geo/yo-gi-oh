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

var player_cards_on_battlefield: Array
var opponent_cards_on_battlefield: Array
var player_cards_attacked_this_turn: Array

func _ready() -> void:
	pass
	#player_health_label.text = str(player_health)
	#opponent_health_label.text = str(opponent_health)
	#for card_slot in monster_card_slots.get_children():
		#empty_monster_card_slots.append(card_slot)

func wait(wait_time) -> void:
	battle_timer.wait_time = wait_time
	battle_timer.start()
	await battle_timer.timeout

func direct_attack(attacking_card) -> void:
	input_manager.input_disabled = true
	enable_end_turn_button(false)
	player_cards_attacked_this_turn.append(attacking_card)
	
	var player_id = multiplayer.get_unique_id()
	rpc("direct_attack_here_and_replicate_peer_opponent", player_id, str(attacking_card.name))
	await direct_attack_here_and_replicate_peer_opponent(player_id, str(attacking_card.name))
	
	
	
	if player_health == 0:
		end_screen.show_end_screen("lost")
		return
	elif opponent_health == 0:
		end_screen.show_end_screen("win")
		return
	
	if attacking_card.ability_script:
		await attacking_card.ability_script.trigger_ability(self, input_manager, attacking_card, "card_attacked")
	input_manager.input_disabled = false
	enable_end_turn_button(true)

@rpc("any_peer")
func direct_attack_here_and_replicate_peer_opponent(player_id, attacking_card_name) -> void:
	var attacking_card
	var attack_pos_y
	if multiplayer.get_unique_id() == player_id:
		attacking_card = card_manager.get_node(attacking_card_name)
		attack_pos_y = -120
	else:
		attacking_card = get_parent().get_parent().get_node("OpponentField/CardManager/" + attacking_card_name)
		attack_pos_y = 120
	
	var new_pos = Vector2(attacking_card.position.x, attack_pos_y)
	attacking_card.z_index = 2
	
	var tween = get_tree().create_tween()
	tween.tween_property(attacking_card, "position", new_pos, card_move_speed)
	await wait(0.15)
	
	if multiplayer.get_unique_id() == player_id:
		opponent_health = max(0, opponent_health - attacking_card.attack)
		get_parent().get_parent().get_node("OpponentField/CanvasLayer/MarginContainer/OpponentHealth").text = str(opponent_health)
	else:
		player_health = max(0, player_health - attacking_card.attack)
		player_health_label.text = str(player_health)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(attacking_card, "position", attacking_card.card_slot_card_is_in.position, card_move_speed)
	attacking_card.z_index = 0
	await wait(1)

func attack(attacking_card, defending_card) -> void:
	card_manager.selected_monster = null
	input_manager.input_disabled = true
	enable_end_turn_button(false)
	player_cards_attacked_this_turn.append(attacking_card)
	
	var player_id = multiplayer.get_unique_id()
	attack_here_and_replicate_peer_opponent(player_id, str(attacking_card.name), str(defending_card.name))
	rpc("attack_here_and_replicate_peer_opponent", player_id, str(attacking_card.name), str(defending_card.name))
	
	if attacking_card.ability_script:
		await attacking_card.ability_script.trigger_ability(self, input_manager, attacking_card, "card_attacked")
	input_manager.input_disabled = false
	enable_end_turn_button(true)

@rpc("any_peer")
func attack_here_and_replicate_peer_opponent(player_id, attacking_card_name, defending_card_name) -> void:
	var attacking_card
	var defending_card
	var y_offset
	
	if multiplayer.get_unique_id() == player_id:
		attacking_card = card_manager.get_node(attacking_card_name)
		defending_card = get_parent().get_parent().get_node("OpponentField/CardManager/" + defending_card_name)
		y_offset = battle_position_offset
	else:
		attacking_card = get_parent().get_parent().get_node("OpponentField/CardManager/" + attacking_card_name)
		defending_card = card_manager.get_node(defending_card_name)
		y_offset = -battle_position_offset
	
	attacking_card.z_index = 2
	var new_pos = Vector2(defending_card.position.x, defending_card.position.y + y_offset)
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
		if multiplayer.get_unique_id() == player_id:
			destroy_card(attacking_card, "player")
		else:
			destroy_card(attacking_card, "opponent")
	if defending_card.health == 0:
		if multiplayer.get_unique_id() == player_id:
			destroy_card(defending_card, "opponent")
		else:
			destroy_card(defending_card, "player")
		card_was_destroyed = true
	
	if card_was_destroyed:
		await wait(1)

func destroy_card(card, card_owner) -> void:
	var new_pos: Vector2
	if card_owner == "player":
		card.get_node("Area2D/CollisionShape2D").disabled = true
		new_pos = player_graveyard.position
		player_cards_on_battlefield.erase(card)
		card.card_slot_card_is_in.get_node("Area2D/CollisionShape2D").disabled = false
	else:
		new_pos = get_parent().get_parent().get_node("OpponentField/OpponentGraveyard").position
		opponent_cards_on_battlefield.erase(card)
	
	card.defeated = true
	card.card_slot_card_is_in.is_card_in_card_slot = false
	card.card_slot_card_is_in = null
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_pos, card_move_speed)
	card.z_index = -1

func opponent_card_selected(defending_card):
	var attacking_card = card_manager.selected_monster
	if attacking_card and defending_card in opponent_cards_on_battlefield:
		attack(attacking_card, defending_card)

func _on_end_turn_button_pressed() -> void:
	enable_end_turn_button(false)
	input_manager.input_disabled = true
	card_manager.unselect_monster()
	for card in player_cards_attacked_this_turn:
		if card.ability_script:
			card.ability_script.reset_ability()
	player_cards_attacked_this_turn.clear()
	rpc("change_turn")

@rpc("any_peer")
func change_turn() -> void:
	player_deck.has_drawn_card_this_turn = false
	card_manager.has_played_monster_card_this_turn = false
	enable_end_turn_button(true)
	input_manager.input_disabled = false

func enable_end_turn_button(is_enabled: bool) -> void:
	end_turn_button.disabled = not is_enabled
	end_turn_button.visible = is_enabled
