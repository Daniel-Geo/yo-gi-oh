extends Node2D

@export var card_collision_mask: int = 1
@export var card_slot_collision_mask: int = 2
@export var card_default_scale: float = 0.8
@export var card_highlight_scale: float = 0.85
@export var card_slot_scale: float = 0.8

@onready var player_hand: Node2D = $"../PlayerHand"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var input_manager: Node2D = $"../InputManager"
@onready var card_draw_speed: float = $"../PlayerDeck".card_draw_speed

var screen_size: Vector2
var card_being_dragged: Node2D
var is_hovering_on_card: bool
var has_played_monster_card_this_turn = false

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

func start_drag(card) -> void:
	card_being_dragged = card
	card.scale = Vector2(card_highlight_scale, card_highlight_scale)


func finish_drag() -> void:
	card_being_dragged.scale = Vector2(card_default_scale, card_default_scale)
	var card_slot = raycast_check(card_slot_collision_mask)
	if card_slot and not card_slot.is_card_in_card_slot:
		if card_being_dragged.card_type == card_slot.card_slot_type:
			if not has_played_monster_card_this_turn:
				has_played_monster_card_this_turn = true
				is_hovering_on_card = false
				card_being_dragged.is_in_card_slot = true
				card_being_dragged.scale = Vector2(card_slot_scale, card_slot_scale)
				card_being_dragged.z_index = -1
				player_hand.remove_card_from_hand(card_being_dragged)
				card_being_dragged.position = card_slot.position
				card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
				card_slot.is_card_in_card_slot = true
				card_being_dragged = null
				return
	
	player_hand.add_card_to_hand(card_being_dragged, card_draw_speed)
	card_being_dragged = null


func connect_card_signals(card) -> void:
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card) -> void:
	if not is_hovering_on_card:
		highlight_card(card, true)
		is_hovering_on_card = true

func on_hovered_off_card(card) -> void:
	if not card.is_in_card_slot and not card_being_dragged:
		highlight_card(card, false)
		var new_card_hovered = raycast_check(card_collision_mask)
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered) -> void:
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
