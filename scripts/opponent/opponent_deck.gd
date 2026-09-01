extends Node2D

@export var starting_hand_size: int = 5
@export var card_draw_speed: float = 0.2

@onready var card_manager: Node2D = $"../CardManager"
@onready var opponent_hand: Node2D = $"../OpponentHand"

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var deck_size: int

func _ready() -> void:
	deck_size = get_parent().get_parent().get_node("PlayerField/PlayerDeck").player_deck.size()
	#rich_text_label.text = str(opponent_deck.size())
	
	#for i in range(starting_hand_size):
		#draw_card()

func draw_card(card_drawn_name) -> void:
	if deck_size - 1 <= 0:
		visible = false
	else:
		deck_size -= 1
		rich_text_label.text = str(deck_size)
	var card_scene = preload("res://scenes/opponent/opponent_card.tscn")
	var new_card = card_scene.instantiate()
	var card_image_path = "res://assets/sprites/" + card_drawn_name + ".png"
	new_card.get_node("%CardImage").texture = load(card_image_path)
	new_card.get_node("%CardImage").visible = false
	new_card.attack = CardDatabase.CARDS[card_drawn_name][0]
	new_card.health = CardDatabase.CARDS[card_drawn_name][1]
	new_card.get_node("%Attack").text = str(new_card.attack)
	new_card.get_node("%Health").text = str(new_card.health)
	new_card.card_type = CardDatabase.CARDS[card_drawn_name][2] as CardDatabase.CardTypes
	if new_card.card_type == CardDatabase.CardTypes.MAGIC:
		new_card.get_node("%Attack").visible = false
		new_card.get_node("%Health").visible = false
	else:
		new_card.get_node("%Attack").visible = true
		new_card.get_node("%Health").visible = true
	card_manager.add_child(new_card)
	new_card.name = "card"
	opponent_hand.add_card_to_hand(new_card, card_draw_speed)
