extends Node2D

@export var card_draw_speed: float = 0.2

@onready var card_manager: Node2D = $"../CardManager"
@onready var player_hand: Node2D = $"../PlayerHand"

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var rich_text_label: RichTextLabel = $RichTextLabel


var player_deck: Array = ["knight", "knight", "knight"]

func _ready() -> void:
	rich_text_label.text = str(player_deck.size())


func draw_card() -> void:
	var card_drawn = player_deck[0]
	player_deck.erase(card_drawn)
	
	if player_deck.size() == 0:
		sprite_2d.visible = false
		rich_text_label.visible = false
		collision_shape_2d.disabled = true
	
	rich_text_label.text = str(player_deck.size())
	var card_scene = preload("res://scenes/card.tscn")
	var new_card = card_scene.instantiate()
	card_manager.add_child(new_card)
	new_card.name = "Card"
	player_hand.add_card_to_hand(new_card, card_draw_speed)
