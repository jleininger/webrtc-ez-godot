@tool
extends EditorPlugin

const AUTOLOAD_NAME = "NetworkManager"


func _enable_plugin() -> void:
	add_autoload_singleton(AUTOLOAD_NAME, "src/NetworkManager.gd")


func _disable_plugin() -> void:
	remove_autoload_singleton(AUTOLOAD_NAME)


func _enter_tree() -> void:
	add_custom_type("Client", "Node", preload("src/WebRTCMultiplayerClient.gd"), preload("icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("Client")
