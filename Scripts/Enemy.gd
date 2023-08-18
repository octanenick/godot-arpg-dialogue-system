extends KinematicBody2D

# Base enemy attributes
var health: int = 100
var enemy_name: String 

# Signal for enemy killed
signal enemy_killed(enemy_name)

# Function to apply damage to the enemy
func apply_damage(damage: int):
	health -= damage
	if health <= 0:
		die()

# Function to handle enemy death
func die():
	print(enemy_name)
	self.emit_signal("enemy_killed", enemy_name)
	queue_free()
