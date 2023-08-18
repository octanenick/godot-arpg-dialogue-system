extends Panel

var quest_manager

func _ready():
	quest_manager = get_node("/root/Node2D/QuestManager")
	quest_manager.connect("quests_updated", self, "update_quest_log")

# Whenever a quest is added or completed, this function updates the UI
func update_quest_log():
	# Reference to the VBoxContainer
	var vbox = $VBoxContainer

	if vbox == null:
		print("Error: VBoxContainer not found!")
		return

	# Clear existing quests
	for child in vbox.get_children():
		child.queue_free()

	# Dynamically create and add new labels for each quest
	for quest in quest_manager.active_quests:
		var quest_label = Label.new()
		quest_label.text = "[ACTIVE] " + quest.description # Prefix with "[ACTIVE]" for active quests
		#quest_label.clip_text = true
		quest_label.autowrap = true
		vbox.add_child(quest_label)
	
	# Optionally, if you want to show completed quests in a different manner
	for quest in quest_manager.completed_quests:
		var quest_label = Label.new()
		quest_label.text = "[COMPLETED] " + quest.description # Prefix with "[COMPLETED]" for completed quests
		#quest_label.clip_text = true
		quest_label.autowrap = true
		vbox.add_child(quest_label)

