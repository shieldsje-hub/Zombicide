
extends Node2D

signal zombie_spawned(zombie: Node)
signal zombie_removed(zombie: Node)

@export var zombie_scene: PackedScene

var zombies: Array[Node] = []


# ==========================================
# SPAWNING
# ==========================================

func spawn_zombie(
	type: int,
	spawn_position: Vector2
) -> Node:

	if zombie_scene == null:
		push_error("Zombie scene not assigned!")
		return null

	var zombie = zombie_scene.instantiate()

	zombie.zombie_type = type

	add_child(zombie)

	zombie.global_position = spawn_position

	zombie.died.connect(_on_zombie_died)

	zombies.append(zombie)

	zombie_spawned.emit(zombie)

	return zombie


# ==========================================
# REMOVAL
# ==========================================

func _on_zombie_died(zombie: Node) -> void:
	zombies.erase(zombie)
	zombie_removed.emit(zombie)


# ==========================================
# ACTIVATION
# ==========================================

func activate_all_zombies() -> void:
	# Use a copy because zombies may die during activation.
	var active_zombies = zombies.duplicate()

	for zombie in active_zombies:
		if is_instance_valid(zombie):
			zombie.activate()


# ==========================================
# INFORMATION
# ==========================================

func get_zombie_count() -> int:
	return zombies.size()


func get_zombie_count_by_type(type: int) -> int:
	var count = 0

	for zombie in zombies:
		if is_instance_valid(zombie):
			if zombie.zombie_type == type:
				count += 1

	return count
