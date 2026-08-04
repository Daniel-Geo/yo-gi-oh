extends Node2D

@export var starting_hand_size: int = 5
@export var card_draw_speed: float = 0.2

@onready var card_manager: Node2D = $"../CardManager"
@onready var player_hand: Node2D = $"../PlayerHand"

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var player_deck: Array = ["knight", "archer", "demon", "knight", "archer", "demon", "knight", "knight"]
var has_drawn_card_this_turn: bool = false

func _ready() -> void:
	player_deck.shuffle()
	rich_text_label.text = str(player_deck.size())
	
	for i in range(starting_hand_size):
		draw_card()
		has_drawn_card_this_turn = false
	has_drawn_card_this_turn = true


func draw_card() -> void:
	if has_drawn_card_this_turn:
		return
	
	has_drawn_card_this_turn = true
	var card_drawn_name = player_deck[0]
	player_deck.erase(card_drawn_name)
	
	if player_deck.size() == 0:
		sprite_2d.visible = false
		rich_text_label.visible = false
		collision_shape_2d.disabled = true
	
	rich_text_label.text = str(player_deck.size())
	var card_scene = preload("res://scenes/card.tscn")
	var new_card = card_scene.instantiate()
	var card_image_path = "res://assets/sprites/" + card_drawn_name + ".png"
	new_card.get_node("%CardImage").texture = load(card_image_path)
	new_card.get_node("%Attack").text = str(CardDatabase.CARDS[card_drawn_name][0])
	new_card.get_node("%Health").text = str(CardDatabase.CARDS[card_drawn_name][1])
	new_card.card_type = CardDatabase.CARDS[card_drawn_name][2] as CardDatabase.CardTypes
	card_manager.add_child(new_card)
	new_card.name = "card"
	player_hand.add_card_to_hand(new_card, card_draw_speed)
	new_card.get_node("AnimationPlayer").play("card_flip")
