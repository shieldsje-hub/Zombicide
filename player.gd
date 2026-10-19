extends CharacterBody2D
#put a step tracker so that the actionhandler can count steps
var actionable : bool = false #make variable to stop actions from being done that the actionhandler can turn off
#add movement
#let player see inventory
#make it so you can shoot
#tell gamehandler when the player is out of actions



















@export var tile_size: int = 32
@export var move_speed: float = 160.0
@export var max_movement: int = 20

@export var movement_left: int = 0
var selecting_path: bool = false
var moving: bool = false

var path: Array[Vector2] = []
var path_line: Line2D


func _ready() -> void:
	position = position.snapped(Vector2(tile_size, tile_size))

	path_line = Line2D.new()
	path_line.width = 4.0
	path_line.default_color = Color.YELLOW
	path_line.z_index = 10
	add_child(path_line)


func _unhandled_input(event: InputEvent) -> void:
	if moving:
		return

	# Shoot toward the mouse when not selecting a path.
	if event.is_action_pressed("f"):
		if not selecting_path:
			shoot_gun()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("enter"):
		if not selecting_path:
			if movement_left <= 0:
				begin_turn()
			else:
				begin_path()
		else:
			confirm_path()

		get_viewport().set_input_as_handled()
		return

	if not selecting_path:
		return

	if event.is_action_pressed("esc"):
		undo_step()
		get_viewport().set_input_as_handled()
		return

	var direction := Vector2.ZERO

	if event.is_action_pressed("w"):
		direction = Vector2.UP
	elif event.is_action_pressed("s"):
		direction = Vector2.DOWN
	elif event.is_action_pressed("a"):
		direction = Vector2.LEFT
	elif event.is_action_pressed("d"):
		direction = Vector2.RIGHT

	if direction != Vector2.ZERO:
		add_path_step(direction)
		get_viewport().set_input_as_handled()


func begin_turn() -> void:
	movement_left = max_movement
	print("New turn! Movement: ", movement_left)
	begin_path()


func begin_path() -> void:
	path.clear()
	path.append(global_position)
	selecting_path = true
	update_path()


func add_path_step(direction: Vector2) -> void:
	if movement_left - (path.size() - 1) <= 0:
		return

	var next_position: Vector2 = path[-1] + direction * tile_size

	if path.size() >= 2 and next_position.is_equal_approx(path[-2]):
		return

	path.append(next_position)
	update_path()


func undo_step() -> void:
	if path.size() > 1:
		path.pop_back()
		update_path()


func update_path() -> void:
	path_line.clear_points()

	for point in path:
		path_line.add_point(to_local(point))


func confirm_path() -> void:
	if path.size() <= 1:
		# Allow cancelling path selection with no movement.
		selecting_path = false
		path.clear()
		path_line.clear_points()
		return

	var selected_path: Array[Vector2] = path.duplicate()
	var steps_used: int = selected_path.size() - 1

	selecting_path = false
	moving = true
	path_line.clear_points()

	for i in range(1, selected_path.size()):
		var target: Vector2 = selected_path[i]

		while global_position.distance_to(target) > 0.5:
			global_position = global_position.move_toward(
				target,
				move_speed * get_process_delta_time()
			)
			await get_tree().process_frame

		global_position = target

	movement_left = max(movement_left - steps_used, 0)

	moving = false
	path.clear()

	# Stay out of path selection so shooting works.
	selecting_path = false

	print("Movement left: ", movement_left)
	print("Press F to shoot or Enter to select another path.")


# ==========================================
# ACTIONS
# ==========================================

func use_action(cost: int) -> bool:
	if moving or selecting_path:
		return false

	if cost < 0 or movement_left < cost:
		print("Not enough movement points!")
		return false

	movement_left -= cost
	print("Action used! Movement left: ", movement_left)
	return true


# ==========================================
# GUN
# ==========================================

func shoot_gun() -> void:
	if use_action(10):
		create_bullet()


func create_bullet() -> void:
	var bullet := Bullet.new()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = global_position
	bullet.direction = (
		get_global_mouse_position() - global_position
	).normalized()


# ==========================================
# BULLET CLASS
# ==========================================

class Bullet extends Node2D:
	var direction: Vector2 = Vector2.RIGHT
	var bullet_speed: float = 500.0
	var distance_travelled: float = 0.0
	var max_distance: float = 500.0
	var bullet_length: float = 14.0

	func _ready() -> void:
		z_index = 100

	func _process(delta: float) -> void:
		var travel := bullet_speed * delta
		global_position += direction * travel
		distance_travelled += travel
		queue_redraw()

		if distance_travelled >= max_distance:
			queue_free()

	func _draw() -> void:
		var end_point := -direction * bullet_length

		draw_line(Vector2.ZERO, end_point, Color.BLACK, 7.0, true)
		draw_line(Vector2.ZERO, end_point, Color.YELLOW, 4.0, true)
