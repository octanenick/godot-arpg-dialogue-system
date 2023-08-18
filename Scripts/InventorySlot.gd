extends TextureRect

var item: Item = null setget set_item
export(String) var slot_type: String = ""

var default_texture = preload("res://textures/UI/slot.jpg")


func set_item(new_item: Item):
	item = new_item
	if item:
		# Assuming you want to set the texture of the slot to represent the item
		self.texture = item.ItemIcon
	else:
		self.texture = default_texture


func has_item() -> bool:
	return item != null
	

func can_accept_item(new_item: Item) -> bool:
	if slot_type == "Weapon" and new_item.ItemType == "Weapon":
		return true
	# Add more conditions for other slots like head, torso, etc.
	# ...

	# Default
	return false
