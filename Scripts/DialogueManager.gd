# DialogueManager.gd
extends Node

#signals
signal request_quest_status(quest_id)
signal start_dialogue(dialogue_text, response_options, portrait_path)

#dialog data variables
var dialogue_data = {}
var current_dialogue = {}
var current_quest_status = ""


func _ready():
	load_dialogues()
	var npcs = get_tree().get_nodes_in_group("NPC") 
	for npc in npcs:
		npc.connect("npc_interacted", self, "_on_npc_interacted")
	
	# Connect to the quest_status_response signal
	var quest_manager = get_node("/root/Node2D/QuestManager")
	quest_manager.connect("quest_status_response", self, "_on_quest_status_response")
	
	# Connect to the dialogue_response signal from DialogueUI
	var dialogue_ui = get_node("/root/Node2D/HUD/DialogueUI")
	dialogue_ui.connect("dialogue_response", self, "_on_dialogue_response")

func load_dialogues():
	var file = File.new()
	file.open("res://Quests/Dialogues.json", File.READ)
	dialogue_data = JSON.parse(file.get_as_text()).result
	file.close()

func _on_npc_interacted(dialogue_id):
	if dialogue_data.has("dialogues"):
		for dialogue in dialogue_data["dialogues"]:
			if dialogue["id"] == dialogue_id:
				current_dialogue = dialogue
				var dialogue_type = current_dialogue.get("type", "unknown")
				match dialogue_type:
					"quest_offer":
						handle_quest_offer_dialogue()
					_:
						print("Unknown dialogue type:", dialogue_type)
				return
	else:
		print("Error: The dialogues data is not loaded correctly.")

func _on_quest_status_response(quest_id, status):
	# Select appropriate text and response options based on quest status
	var dialogue_text = ""
	var response_options = {}
	current_quest_status = status
	
	if current_dialogue.has("text") and current_dialogue["text"].has(status):
		dialogue_text = current_dialogue["text"][status]
	else:
		print("Error: The dialogue data does not have the appropriate status.")
		return
	
	if current_dialogue.has("response") and current_dialogue["response"].has(status):
		response_options = current_dialogue["response"][status]
	else:
		print("Error: The dialogue data does not have the appropriate response options.")
		return
	
	# Emit a signal to the DialogueUI with the selected text and response options
	emit_signal("start_dialogue", dialogue_text, response_options, current_dialogue["portrait"], current_quest_status)

func _on_dialogue_response(action, parameter):
	match action:
		"close_dialogue":
			# Do nothing or close any additional UI elements if needed
			pass
		"start_quest":
			if parameter != null:
				var quest_manager = get_node("/root/Node2D/QuestManager")
				quest_manager.start_quest_by_id(parameter)
		"accept_reward":
			if parameter != null:
				var quest_manager = get_node("/root/Node2D/QuestManager")
				quest_manager.accept_reward(parameter)
		_:
			print("Unknown action:", action)

func handle_quest_offer_dialogue():
	var quest_id = current_dialogue.get("quest_id", "")
	if quest_id == "":
		print("Error: The quest_id is missing in the dialogue.")
		return
	# Emit the signal asking for the quest status
	emit_signal("request_quest_status", quest_id)
