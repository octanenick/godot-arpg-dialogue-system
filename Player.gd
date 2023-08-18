#Player.gd
extends KinematicBody2D


var velocity: Vector2 = Vector2()
var direction: Vector2 = Vector2()
var speed = 200
var health = 100 setget set_health
var attack_strength = 10

var is_frozen = false
var current_npc = null


var inventory = []
signal inventory_toggled

var quest_manager = null

onready var attack_area: Area2D = $AttackArea

signal health_changed(new_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)

var in_interaction_zone = false  

func _ready():
	hide_interaction_hint()
	get_node("/root/Node2D/HUD/DialogueUI").hide_dialogue()
	
	quest_manager = get_node("/root/Node2D/QuestManager")
	get_node("/root/Node2D/HUD/DialogueUI").connect("dialogue_response", self, "_on_dialogue_response")


func read_input():
	velocity = Vector2()
	
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory()
		
	if Input.is_action_just_pressed("toggle_questlog"):
		toggle_questlog()
	
	if Input.is_action_just_pressed("attack"):
		execute_attack()
	if not is_frozen:
		if Input.is_action_pressed("ui_up"):
			velocity.y -= 1
			direction = Vector2(0, -1)
		
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
			direction = Vector2(0, 1)
			
		if Input.is_action_pressed("ui_left"):
			velocity.x -= 1
			direction = Vector2(-1, 0)
			
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
			direction = Vector2(1, 0)

	velocity = velocity.normalized()
	velocity = move_and_slide(velocity * speed)
	
func _process(delta):
	read_input()
	
	if in_interaction_zone and Input.is_action_just_pressed("ui_select"):
		in_interaction_zone = false
		# Directly start the dialogue using the current NPC's dialogue_id
		_on_npc_interacted(current_npc.dialogue_id)


func show_interaction_hint():
	get_node("/root/Node2D/HUD/SpeakHint").visible = true
	get_node("/root/Node2D/HUD/SpeakHint").text = "Speak (X)"

func hide_interaction_hint():
	get_node("/root/Node2D/HUD/SpeakHint").visible = false
	

func _on_npc_interacted(dialogue_id):
	print(dialogue_id)


func get_quest_status(quest_id: int):
	var quest = quest_manager.get_quest_by_id(quest_id)
	if quest:
		return quest.status
	return Quest.QuestStatus.NOT_STARTED

func execute_attack():
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("Enemy"):
			var direction_to_enemy = (body.global_position - global_position).normalized()
			if direction.dot(direction_to_enemy) > 0.5:  # This checks if the enemy is roughly in the player's facing direction
				body.apply_damage(attack_strength)

func toggle_inventory():
	var inventory_panel = get_node("/root/Node2D/HUD/Inventory")
	inventory_panel.visible = !inventory_panel.visible
	emit_signal("inventory_toggled", inventory_panel.visible)
	
	is_frozen = !is_frozen
	
func toggle_questlog():
	var questlog = get_node("/root/Node2D/HUD/QuestLog")
	questlog.visible = !questlog.visible
	emit_signal("questlog_toggled", questlog.visible)
	
	is_frozen = !is_frozen

func add_to_inventory(item: Item):
	inventory.append(item)
	
	# Example: Print the name of the item
	print(item.ItemName)
	
	# If the inventory system has a visual component, update it here.
	call_deferred("_add_item_to_inventory_ui", item)

func _add_item_to_inventory_ui(item: Item):
	get_node("/root/Node2D/HUD/Inventory").add_item_to_slot(item)


func _on_dialogue_response(action, parameter):
	match action:
		"start_quest":
			quest_manager.start_quest_by_id(parameter)
		"close_dialogue":
			# Logic to close the dialogue, if required
			pass
		# Add more cases as needed



# Function to apply damage to the player
func apply_damage(damage: int):
	health -= damage
	emit_signal("health_changed", health)
	if health <= 0:
		die()

# Function to handle player death
func die():
	# Handle player death here. It could be game over, respawning, etc.
	# For example, you could reload the scene to restart the level
	get_tree().reload_current_scene()
