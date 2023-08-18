#NPC.gd
extends Node

export(String) var dialogue_id
signal npc_interacted(dialogue_id)

export(Dictionary) var quest_dialogues = {
	"available": "",
	"active": "",
	"completed": ""
}

export(Texture) var npc_image

var in_interaction_zone = false

func get_npc_image() -> Texture:
	return npc_image
	
onready var sprite_node = $Sprite

func _ready():
	if sprite_node and npc_image:
		sprite_node.texture = npc_image

func _physics_process(delta):
	var dialogue_ui = get_node("/root/Node2D/HUD/DialogueUI") # Get a reference to the DialogueUI node
	if in_interaction_zone and Input.is_action_just_pressed("ui_select") and not dialogue_ui.is_active:
		emit_signal("npc_interacted", dialogue_id)
		yield(dialogue_ui, "dialogue_closed") # Wait for the dialogue to be closed before continuing
		in_interaction_zone = false

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		body.show_interaction_hint()
		in_interaction_zone = true

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		body.hide_interaction_hint()
		in_interaction_zone = false
		print("Player exited NPC's interaction zone!")
