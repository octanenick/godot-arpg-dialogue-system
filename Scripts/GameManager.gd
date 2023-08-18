extends Node

func _ready():
	# Connect the dialogue UI to the Quest Manager and Player
	get_node("/root/Node2D/HUD/DialogueUI").connect("dialogue_response", get_node("/root/Node2D/QuestManager"), "_on_dialogue_response")
	get_node("/root/Node2D/HUD/DialogueUI").connect("dialogue_response", get_node("/root/Node2D/Player"), "_on_dialogue_response")
	# Add more connections as needed
