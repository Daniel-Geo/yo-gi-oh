extends Node2D

@export var player_field_scene: PackedScene
@export var opponent_field_scene: PackedScene

@onready var host: Button = $CanvasLayer/MarginContainer/VBoxContainer/Host
@onready var join: Button = $CanvasLayer/MarginContainer/VBoxContainer/Join

const SERVER_ADDRESS: String = "localhost"
const PORT: int = 1024

var peer = ENetMultiplayerPeer.new()


func _on_host_pressed() -> void:
	disable_buttons()
	
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(on_peer_connected)
	
	var player_field_instance = player_field_scene.instantiate()
	add_child(player_field_instance)

func _on_join_pressed() -> void:
	disable_buttons()
	
	peer.create_client(SERVER_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
	var player_field_instance = player_field_scene.instantiate()
	add_child(player_field_instance)
	
	var opponent_field_instance = opponent_field_scene.instantiate()
	add_child(opponent_field_instance)
	
	player_field_instance.client_setup()

func on_peer_connected(peer_id) -> void:
	var opponent_field_instance = opponent_field_scene.instantiate()
	add_child(opponent_field_instance)
	get_node("PlayerField").host_setup()

func disable_buttons() -> void:
	host.disabled = true
	host.visible = false
	join.disabled = true
	join.visible = false
	
