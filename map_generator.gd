extends Node2D
var gridsize = (3)
var maparray = []
var squares = preload("square.tscn")
var wall = preload("res://wall.tscn")
var wallstage = int(0)
var go = bool(false)
var time = 0.0
var tilesize = 10.0
var wallsize = 2.0
@onready var debug_camera: Camera2D = $"Debug camera"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()
	print(maparray)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("w"):
		debug_camera.position.y -= 10 * delta * -debug_camera.zoom.x 
	if Input.is_action_pressed("s"):
		debug_camera.position.y += 10 * delta * -debug_camera.zoom.x 
	if Input.is_action_pressed("a"):
		debug_camera.position.x -= 10 * delta * -debug_camera.zoom.x 
	if Input.is_action_pressed("d"):
		debug_camera.position.x += 10 * delta * -debug_camera.zoom.x 
	if Input.is_action_pressed("p"):
		debug_camera.zoom += Vector2(delta * 10, delta * 10)
	if Input.is_action_pressed("o"):
		debug_camera.zoom -= Vector2(delta * 10, delta * 10)
	
	
	
	
	
	
	
	
	
	
	
func generate():
	for x in range(gridsize):
		for y in range(gridsize):
			var squarematch = squares.instantiate()
			squarematch.global_position = Vector2(x * tilesize, y * tilesize)
			squarematch.scale = Vector2(tilesize, tilesize)
			add_child(squarematch)
			maparray.append(Vector2(x,y))
			if y == 0:
				wallstage = 0
				wall_generate(squarematch)
			if x == 0:
				wallstage = 3
				wall_generate(squarematch)
			if y == gridsize - 1:
				wallstage = 2
				wall_generate(squarematch)
			if x == gridsize - 1:
				wallstage = 1
				wall_generate(squarematch)
func wall_generate(squarematch):
	var newwall = wall.instantiate()
	if wallstage == 0:
		newwall.global_position.y = squarematch.global_position.y - (squarematch.scale.y / 2)
		newwall.scale.x = tilesize
		newwall.scale.y = wallsize
		newwall.global_position.x = squarematch.global_position.x
		add_child(newwall)
	elif wallstage == 1:
		newwall.global_position.x = squarematch.global_position.x + (squarematch.scale.x / 2)
		newwall.scale.y = tilesize 
		newwall.scale.x = wallsize
		newwall.global_position.y = squarematch.global_position.y
		add_child(newwall)
	elif wallstage == 2:
		
		newwall.global_position.y = squarematch.global_position.y + (squarematch.scale.y / 2)
		newwall.scale.x = tilesize
		newwall.scale.y = wallsize
		newwall.global_position.x = squarematch.global_position.x
		add_child(newwall)
	elif wallstage == 3:
		newwall.global_position.x = squarematch.global_position.x - (squarematch.scale.x / 2)
		newwall.scale.y = tilesize
		newwall.scale.x = wallsize
		newwall.global_position.y = squarematch.global_position.y
		add_child(newwall)
