
extends Node2D

signal died(zombie: Node)
signal activated(zombie: Node)

enum ZombieType {
	WALKER,
	RUNNER,
	FATTY,
	ABOMINATION
}

@export var zombie_type: ZombieType = ZombieType.WALKER

var health: int = 1
var max_health: int = 1
var actions_per_activation: int = 1

var tile_position: Vector2 = Vector2.ZERO
var is_dead: bool = false

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D")
@onready var count_label: Label = get_node_or_null("Label")


func _ready() -> void:
	configure_zombie()
	update_visuals()


# ==========================================
# ZOMBIE CONFIGURATION
# ==========================================

func configure_zombie() -> void:
	match zombie_type:
		ZombieType.WALKER:
			max_health = 1
			actions_per_activation = 1

		ZombieType.RUNNER:
			max_health = 1
			actions_per_activation = 2

		ZombieType.FATTY:
			max_health = 2
			actions_per_activation = 1

		ZombieType.ABOMINATION:
			max_health = 3
			actions_per_activation = 1

	health = max_health


func get_zombie_type_name() -> String:
	match zombie_type:
		ZombieType.WALKER:
			return "Walker"
		ZombieType.RUNNER:
			return "Runner"
		ZombieType.FATTY:
			return "Fatty"
		ZombieType.ABOMINATION:
			return "Abomination"

	return "Unknown"


# ==========================================
# HEALTH
# ==========================================

func take_damage(amount: int) -> void:
	if is_dead or amount <= 0:
		return

	health -= amount

	if health <= 0:
		die()
	else:
		update_visuals()


func die() -> void:
	if is_dead:
		return

	is_dead = true
	died.emit(self)
	queue_free()


# ==========================================
# ACTIVATION
# ==========================================

func activate() -> void:
	if is_dead:
		return

	for action in range(actions_per_activation):
		activated.emit(self)

		if is_dead:
			return


# ==========================================
# VISUALS
# ==========================================

func update_visuals() -> void:
	if sprite != null:
		match zombie_type:
			ZombieType.WALKER:
				sprite.modulate = Color.GREEN

			ZombieType.RUNNER:
				sprite.modulate = Color.YELLOW

			ZombieType.FATTY:
				sprite.modulate = Color.ORANGE

			ZombieType.ABOMINATION:
				sprite.modulate = Color.RED

	if count_label != null:
		count_label.text = get_zombie_type_name()
