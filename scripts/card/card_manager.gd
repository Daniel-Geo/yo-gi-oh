extends Node2D

@export var card_draw_speed: float = 0.2
@export var card_collision_mask: int = 1
@export var card_slot_collision_mask: int = 2
@export var card_default_scale: float = 0.8
@export var card_highlight_scale: float = 0.85
@export var card_slot_scale: float = 0.8
@export var selected_monster_offset_y: int = 10

@onready var player_hand: Node2D = $"../PlayerHand"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var input_manager: Node2D = $"../InputManager"
@onready var battle_manager: Node = $"../BattleManager"

var screen_size: Vector2
var card_being_dragged: Node2D
var is_hovering_on_card: bool
var selected_monster: Node2D
var has_played_monster_card_this_turn: bool = false

func _ready() -> void:
	screen_size = get_viewport_rect().size / camera_2d.zoom
	input_manager.connect("left_mouse_button_released", on_left_mouse_button_released)

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_position = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_position.x, -screen_size.x/2, screen_size.x/2), clamp(mouse_position.y, -screen_size.y/2, screen_size.y/2))

func on_left_mouse_button_released() -> void:
	if card_being_dragged:
		finish_drag()

func card_clicked(card) -> void:
	if card.card_slot_card_is_in:
		if not card in battle_manager.player_cards_attacked_this_turn:
			if card.card_type == CardDatabase.CardTypes.MONSTER:
				if battle_manager.opponent_cards_on_battlefield.size() == 0:
					battle_manager.direct_attack(card)
				else:
					select_card_to_be_attacked(card)
	else:
		start_drag(card)

func select_card_to_be_attacked(card) -> void:
	if selected_monster:
		if selected_monster == card:
			card.position.y += selected_monster_offset_y
			card.z_index = 1
			selected_monster = null
		else:
			selected_monster.position.y += selected_monster_offset_y
			selected_monster.z_index = 1
			selected_monster = card
			card.position.y -= selected_monster_offset_y
			card.z_index = 2
	else:
		selected_monster = card
		card.position.y -= selected_monster_offset_y
		card.z_index = 2

func unselect_monster() -> void:
	if selected_monster:
		selected_monster.position.y += selected_monster_offset_y
		selected_monster.z_index = 1
		selected_monster = null

func start_drag(card) -> void:
	card_being_dragged = card
	card.scale = Vector2(card_highlight_scale, card_highlight_scale)


func finish_drag() -> void:
	card_being_dragged.scale = Vector2(card_default_scale, card_default_scale)
	var card_slot = raycast_check(card_slot_collision_mask)
	if card_slot and not card_slot.is_card_in_card_slot:
		if card_being_dragged.card_type == card_slot.card_slot_type:
			if card_being_dragged.card_type == CardDatabase.CardTypes.MONSTER and has_played_monster_card_this_turn:
				player_hand.add_card_to_hand(card_being_dragged, card_draw_speed)
				card_being_dragged = null
				return
			
			var player_id = multiplayer.get_unique_id()
			play_card_here_and_for_peer_opponent(player_id, str(card_being_dragged.name), str(card_slot.name))
			rpc("play_card_here_and_for_peer_opponent", player_id, str(card_being_dragged.name), str(card_slot.name))
			card_being_dragged.is_in_card_slot = true
			
			if card_being_dragged.card_type == CardDatabase.CardTypes.MONSTER:
				battle_manager.player_cards_on_battlefield.append(card_being_dragged)
				has_played_monster_card_this_turn = true
			
			if card_being_dragged.ability_script:
				card_being_dragged.ability_script.trigger_ability(battle_manager, input_manager, card_being_dragged, "card_placed")
			card_being_dragged = null
			return
	
	player_hand.add_card_to_hand(card_being_dragged, card_draw_speed)
	card_being_dragged = null

@rpc("any_peer")
func play_card_here_and_for_peer_opponent(player_id, card_name, card_slot_name) -> void:
	var card
	var card_slot = $"../PlayerCardSlots".get_node(card_slot_name)
	if multiplayer.get_unique_id() == player_id:
		card = get_node(card_name)
		is_hovering_on_card = false
		player_hand.remove_card_from_hand(card)
		card.position = card_slot.position
		card_slot.get_node("Area2D/CollisionShape2D").disabled = true
	else:
		var opponent_field = get_parent().get_parent().get_node("OpponentField")
		card = opponent_field.get_node("CardManager/" + card_name)
		card_slot = opponent_field.get_node("OpponentCardSlots/" + card_slot_name)
		opponent_field.get_node("OpponentHand").remove_card_from_hand(card)
		var tween = get_tree().create_tween()
		tween.tween_property(card, "position", card_slot.position, card_draw_speed)
		card.get_node("AnimationPlayer").play("card_flip")
		battle_manager.opponent_cards_on_battlefield.append(card)
	
	card.scale = Vector2(card_slot_scale, card_slot_scale)
	card.z_index = -1
	card.card_slot_card_is_in = card_slot
	card_slot.is_card_in_card_slot = true

func connect_card_signals(card) -> void:
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card) -> void:
	if not is_hovering_on_card and not card.is_in_card_slot:
		highlight_card(card, true)
		is_hovering_on_card = true

func on_hovered_off_card(card) -> void:
	if not card.is_in_card_slot and not card_being_dragged and not card.defeated:
		highlight_card(card, false)
		var new_card_hovered = raycast_check(card_collision_mask)
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered) -> void:
	if card.card_slot_card_is_in:
		return
	if hovered:
		card.scale = Vector2(card_highlight_scale, card_highlight_scale)
		card.z_index = 2
	else:
		card.scale = Vector2(card_default_scale, card_default_scale)
		card.z_index = 1

func raycast_check(collision_mask) -> Node2D:
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		if collision_mask == card_collision_mask:
			return result[0].collider.get_parent()
		else:
			return get_card_with_highest_z_index(result)
	return null

func  get_card_with_highest_z_index(cards) -> Node2D:
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	
	for i in range(1, cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
