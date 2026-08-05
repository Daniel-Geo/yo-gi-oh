extends Node2D

@export var starting_hand_size: int = 5
@export var card_draw_speed: float = 0.2

@onready var card_manager: Node2D = $"../CardManager"
@onready var opponent_hand: Node2D = $"../OpponentHand"

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var rich_text_label: RichTextLabel = $RichTextLabel

var opponent_deck: Array = ["knight", "archer", "demon", "knight", "archer", "demon", "knight", "knight", "knight"]

func _ready() -> void:
	opponent_deck.shuffle()
	rich_text_label.text = str(opponent_deck.size())
	
	for i in range(starting_hand_size):
		draw_card()


func draw_card() -> void:
	var card_drawn_name = opponent_deck[0]
	opponent_deck.erase(card_drawn_name)
	
	if opponent_deck.size() == 0:
		sprite_2d.visible = false
		rich_text_label.visible = false
	
	rich_text_label.text = str(opponent_deck.size())
	var card_scene = preload("res://scenes/opponent_card.tscn")
	var new_card = card_scene.instantiate()
	var card_image_path = "res://assets/sprites/" + card_drawn_name + ".png"
	new_card.get_node("%CardImage").texture = load(card_image_path)
	new_card.get_node("%CardImage").visible = false
	new_card.attack = CardDatabase.CARDS[card_drawn_name][0]
	new_card.get_node("%Attack").text = str(new_card.attack)
	new_card.get_node("%Health").text = str(CardDatabase.CARDS[card_drawn_name][1])
	new_card.card_type = CardDatabase.CARDS[card_drawn_name][2] as CardDatabase.CardTypes
	card_manager.add_child(new_card)
	new_card.name = "card"
	opponent_hand.add_card_to_hand(new_card, card_draw_speed)
