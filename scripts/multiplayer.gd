extends Node2D

@export var player_field_scene: PackedScene
@export var opponent_field_scene: PackedScene

@onready var host: Button = $CanvasLayer/MarginContainer/VBoxContainer/VBoxContainer/Host

@onready var host_ip_address: LineEdit = $CanvasLayer/MarginContainer/VBoxContainer/VBoxContainer2/HostIPAddress
@onready var join: Button = $CanvasLayer/MarginContainer/VBoxContainer/VBoxContainer2/Join
@onready var tip: Label = $CanvasLayer/MarginContainer/VBoxContainer/VBoxContainer2/Tip

const PORT: int = 1024

var server_address: String

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
	
	server_address = host_ip_address.text
	
	peer.create_client(server_address, PORT)
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
	host_ip_address.process_mode = Node.PROCESS_MODE_DISABLED
	host_ip_address.visible = false
	tip.visible = false
