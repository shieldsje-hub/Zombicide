
extends Node

signal turn_changed(player: Node)
signal phase_changed(phase: String)

const MAX_PLAYERS: int = 6

var players: Array[Node] = []
var current_player_index: int = 0
var current_phase: String = "PLAYER"
var game_started: bool = false
var changing_turn: bool = false

var player_levels: Dictionary = {}
var player_inventories: Dictionary = {}

var turn_panel: PanelContainer
var turn_label: Label
var turn_bar: ProgressBar
var turn_order_label: Label
var end_turn_button: Button


func _ready() -> void:
	create_turn_ui()


# ==========================================
# PLAYER REGISTRATION
# ==========================================

func register_player(player: Node) -> void:
	if not is_instance_valid(player):
		return

	if players.has(player):
		return

	if players.size() >= MAX_PLAYERS:
		push_warning("Maximum of 6 players reached.")
		return

	players.append(player)

	var id: int = player.get_instance_id()

	player_levels[id] = 1
	player_inventories[id] = []

	if player.has_method("set_turn_active"):
		player.set_turn_active(false)

	print("Registered player: ", player.name)

	update_turn_ui()

	if not game_started:
		game_started = true
		current_player_index = 0
		start_player_turn()


func unregister_player(player: Node) -> void:
	var index: int = players.find(player)

	if index == -1:
		return

	var was_current_player: bool = (
		index == current_player_index
	)

	players.remove_at(index)

	var id: int = player.get_instance_id()

	player_levels.erase(id)
	player_inventories.erase(id)

	if players.is_empty():
		game_started = false
		current_player_index = 0
		current_phase = "PLAYER"
		changing_turn = false
		update_turn_ui()
		return

	if index < current_player_index:
		current_player_index -= 1
	elif was_current_player:
		current_player_index %= players.size()

	current_player_index = clampi(
		current_player_index,
		0,
		players.size() - 1
	)

	update_turn_ui()

	if was_current_player and not changing_turn:
		start_player_turn()


# ==========================================
# TURN MANAGEMENT
# ==========================================

func get_current_player() -> Node:
	if players.is_empty():
		return null

	if current_player_index < 0:
		return null

	if current_player_index >= players.size():
		return null

	var player: Node = players[current_player_index]

	if not is_instance_valid(player):
		return null

	return player


func is_player_turn(player: Node) -> bool:
	return (
		game_started
		and not changing_turn
		and current_phase == "PLAYER"
		and get_current_player() == player
	)


func can_player_act(player: Node) -> bool:
	return is_player_turn(player)


func start_player_turn() -> void:
	if players.is_empty():
		return

	current_player_index = posmod(
		current_player_index,
		players.size()
	)

	current_phase = "PLAYER"
	changing_turn = false

	var player: Node = get_current_player()

	if player == null:
		return

	if player.has_method("start_player_turn"):
		player.start_player_turn()

	update_turn_ui()

	turn_changed.emit(player)
	phase_changed.emit(current_phase)

	print("Turn started: ", player.name)


func end_player_turn(player: Node) -> void:
	if not is_player_turn(player):
		return

	if player.get("moving") == true:
		return

	changing_turn = true

	if player.has_method("set_turn_active"):
		player.set_turn_active(false)

	current_phase = "END"

	update_turn_ui()
	phase_changed.emit(current_phase)

	await get_tree().process_frame

	if not is_inside_tree():
		return

	if players.is_empty():
		changing_turn = false
		return

	var old_index: int = players.find(player)

	if old_index >= 0:
		current_player_index = (
			old_index + 1
		) % players.size()
	else:
		current_player_index = posmod(
			current_player_index,
			players.size()
		)

	start_player_turn()


# ==========================================
# PLAYER LEVELS
# ==========================================

func get_player_level(player: Node) -> int:
	return int(
		player_levels.get(player.get_instance_id(), 1)
	)


func set_player_level(player: Node, level: int) -> void:
	player_levels[player.get_instance_id()] = maxi(
		1,
		level
	)


# ==========================================
# PLAYER INVENTORIES
# ==========================================

func get_player_inventory(player: Node) -> Array:
	return player_inventories.get(
		player.get_instance_id(),
		[]
	)


func add_item_to_inventory(
	player: Node,
	item: Variant
) -> void:
	var id: int = player.get_instance_id()

	if not player_inventories.has(id):
		player_inventories[id] = []

	player_inventories[id].append(item)


# ==========================================
# TURN UI
# ==========================================

func create_turn_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.name = "TurnCanvas"
	add_child(canvas)

	turn_panel = PanelContainer.new()
	turn_panel.name = "TurnPanel"

	turn_panel.set_anchors_preset(
		Control.PRESET_TOP_RIGHT
	)

	turn_panel.position = Vector2(-300, 15)
	turn_panel.custom_minimum_size = Vector2(285, 0)

	canvas.add_child(turn_panel)

	var layout := VBoxContainer.new()
	turn_panel.add_child(layout)

	turn_label = Label.new()
	turn_label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)
	layout.add_child(turn_label)

	turn_bar = ProgressBar.new()
	turn_bar.min_value = 0
	turn_bar.max_value = 100
	turn_bar.show_percentage = false
	layout.add_child(turn_bar)

	turn_order_label = Label.new()
	turn_order_label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD
	)
	layout.add_child(turn_order_label)

	end_turn_button = Button.new()
	end_turn_button.text = "End Turn"
	end_turn_button.focus_mode = Control.FOCUS_NONE

	end_turn_button.pressed.connect(
		_on_end_turn_pressed
	)

	layout.add_child(end_turn_button)

	update_turn_ui()


func update_turn_ui() -> void:
	if turn_label == null:
		return

	var player: Node = get_current_player()

	if player == null:
		turn_label.text = "Waiting for players"
	else:
		match current_phase:
			"PLAYER":
				turn_label.text = (
					"PLAYER TURN: " + player.name
				)
			"END":
				turn_label.text = "Ending turn..."

	if players.is_empty():
		turn_bar.value = 0
	else:
		turn_bar.value = (
			float(current_player_index + 1)
			/ float(players.size())
		) * 100.0

	var text: String = "TURN ORDER\n"

	for i in range(players.size()):
		var entry: String = (
			str(i + 1) + ". " + players[i].name
		)

		if (
			i == current_player_index
			and current_phase == "PLAYER"
		):
			entry = "> " + entry + " (ACTIVE)"

		text += entry + "\n"

	turn_order_label.text = text

	var player_is_moving: bool = (
		player != null
		and player.get("moving") == true
	)

	end_turn_button.disabled = (
		player == null
		or current_phase != "PLAYER"
		or changing_turn
		or player_is_moving
	)


func _on_end_turn_pressed() -> void:
	if changing_turn:
		return

	end_turn_button.release_focus()

	var player: Node = get_current_player()

	if player != null:
		end_player_turn(player)
