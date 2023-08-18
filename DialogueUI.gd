# DialogueUI
extends Node2D

var is_active = false

var dialogue_manager = DialogueManager
onready var npc_portrait = $Panel/Sprite
signal dialogue_response(action, parameter)
signal dialogue_closed()

var current_quest_status = ""

func _ready():
	dialogue_manager.connect("start_dialogue", self, "show_dialogue")

func _input(event):
	if not is_active:
		return

	if Input.is_action_just_pressed("ui_select"):
		handle_response_from_ui("AcceptButton")
		hide_dialogue()
	elif Input.is_action_just_pressed("ui_cancel"):
		handle_response_from_ui("DeclineButton")

func handle_response_from_ui(button_name: String):
	var button = $Panel.get_node(button_name)
	var response_text = button.text

	for key in dialogue_manager.current_dialogue["response"]:
		for response_key in dialogue_manager.current_dialogue["response"][key]:
			var response = dialogue_manager.current_dialogue["response"][key][response_key]
			if response["text"] == response_text:
				handle_response(response_key)
				return
	

func handle_response(response_key):
	if not dialogue_manager.current_dialogue["response"][current_quest_status].has(response_key):
		print("Error: The response key", response_key, "is not present in the current dialogue for quest status", current_quest_status, ".")
		return

	var response_data = dialogue_manager.current_dialogue["response"][current_quest_status][response_key]
	var action = response_data["action"]
	var parameter = response_data.get("parameter", null)
	emit_signal("dialogue_response", action, parameter)
	hide_dialogue()



func show_dialogue(text, responses, portrait_path, quest_status):
	current_quest_status = quest_status
	$Panel/DialogueText.text = text

	# Display response options
	if responses.has("accept"):
		$Panel/AcceptButton.text = responses["accept"]["text"]
		$Panel/AcceptButton.visible = true
	else:
		$Panel/AcceptButton.visible = false

	if responses.has("decline"):
		$Panel/DeclineButton.text = responses["decline"]["text"]
		$Panel/DeclineButton.visible = true
	else:
		$Panel/DeclineButton.visible = false

	var portrait_texture = load(portrait_path)
	npc_portrait.texture = portrait_texture
	
	self.visible = true
	is_active = true


func hide_dialogue():
	self.visible = false
	is_active = false  
	emit_signal("dialogue_closed")

