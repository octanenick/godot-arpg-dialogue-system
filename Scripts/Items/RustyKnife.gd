extends Item

class_name RustyKnife

func _init():
	ItemName = "Rusty Knife"
	ItemIcon = preload("res://textures/Items/rusty-knife.png") # Make sure to replace this with the actual path to your icon
	ItemType = "Weapon"
	var attack_strength = 5
