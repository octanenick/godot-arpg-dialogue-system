extends "res://Scripts/Enemy.gd"  # Inherit from the base Enemy class

class_name EnemyAnt


var speed = 100
var player_detected = false
var player: Node

var attack_range = 70  # The range in which the ant can attack the player
var attack_damage = 5
var attack_delay = 1.0  # The delay between consecutive attacks in seconds
var can_attack = true

func _ready():
	enemy_name = "ant"
	

func _physics_process(delta):
	if player_detected:
		var direction = (player.global_position - global_position).normalized()
		move_and_slide(direction * speed)
		
		if can_attack:
			attack()

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		player_detected = true
		player = body

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		player_detected = false

func attack():
	if player.global_position.distance_to(global_position) <= attack_range:
		player.apply_damage(attack_damage)  # Call the player's apply_damage method
		print("Player is attacked! Health: ", player.health)
		can_attack = false
		yield(get_tree().create_timer(attack_delay), "timeout")
		can_attack = true
