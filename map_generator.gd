extends Node2D
var gridsize = (10)
var maparray = []
var squares = preload("square.tscn")
var wall = preload("res://wall.tscn")
var wallstage = int(0)
var go = bool(false)
var time = 0.0
var tilesize = 10.0
var wallsize = 2.0
var roomnumber = int(10)
var roomtype = int(1)
var roomsgen = int(0)
var tiley = float(0.0)
var tilex = float(0.0)
var location = Vector2(0.0, 0.0)
var doorpos = (5)
var doornum = 0
var walls = [] 
# 0 is 2x2, 1 is 4x2, 2 is 4x4, 3 is 4x2
@onready var debug_camera: Camera2D = $"Debug camera"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()
	room_generate()
	print(maparray)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("w"): #just to control the camera as I don't know how to do it regularly
		debug_camera.position.y += 10 * delta * -debug_camera.zoom.x 
	if Input.is_action_pressed("s"):
		debug_camera.position.y -= 10 * delta * -debug_camera.zoom.x 
	if Input.is_action_pressed("a"):
		debug_camera.position.x += 10 * delta * -debug_camera.zoom.x 
	if Input.is_action_pressed("d"):
		debug_camera.position.x -= 10 * delta * -debug_camera.zoom.x 
	if Input.is_action_pressed("p"):
		debug_camera.zoom += Vector2(delta * 10, delta * 10)
	if Input.is_action_pressed("o"):
		debug_camera.zoom -= Vector2(delta * 10, delta * 10)
	
	
	
	
	
	
	
	
	
	
	
func generate(): #this code generates the floor sprites, as well as the outer wall and coordinates
	for x in range(gridsize):
		for y in range(gridsize):
			var squarematch = squares.instantiate()
			squarematch.global_position = Vector2(x * tilesize, y * tilesize)
			squarematch.scale = Vector2(tilesize, tilesize)
			add_child(squarematch)
			maparray.append(Vector2(x * tilesize, y * tilesize))
			tiley = squarematch.global_position.y #- tilesize/2
			tilex = squarematch.global_position.x #- tilesize/2
			if y == 0:
				wallstage = 0
				wall_generate()
			if x == 0:
				wallstage = 3
				wall_generate()
			if y == gridsize - 1:
				wallstage = 2
				wall_generate()
			if x == gridsize - 1:
				wallstage = 1
				wall_generate()
func room_generate():
	for I in range(roomnumber):
		roomtype = 0#randi_range(0,3) #change this to generate rooms based on set conditions
		if roomtype == 0: #2x2
			if I == 0:
				tilex = 0.0
				tiley = 0.0
			else:
				var positions = maparray.filter(
				func(pos):
					return pos.x <= (gridsize - 3) * tilesize and pos.y <= (gridsize - 3) * tilesize)
				location = positions.pick_random()
				tilex = location.x
				tiley = location.y
			if not tiley == 0.0:
				walls.append({ "x": tilex, "y": tiley, "stage": 0 })
				walls.append({ "x": tilex + tilesize, "y": tiley, "stage": 0 })
			if not tilex == 0.0:
				walls.append({ "x": tilex, "y": tiley, "stage": 3 })
				walls.append({ "x": tilex, "y": tiley + tilesize, "stage": 3 })
			if not tilex == gridsize - 1:
				walls.append({ "x": tilex + tilesize, "y": tiley, "stage": 1 })
				walls.append({ "x": tilex + tilesize, "y": tiley + tilesize, "stage": 1 })
			if not tilex == gridsize - 1:
				walls.append({ "x": tilex + tilesize, "y": tiley + tilesize, "stage": 2 })
				walls.append({ "x": tilex, "y": tiley + tilesize, "stage": 2 })
			for i in walls:
				wallstage = i.stage
				tilex = i.x
				tiley = i.y
				wall_generate()
		elif roomtype == 1: #3x3
			if I == 0:
				tilex = 0.0
				tiley = 0.0
			else:
				var positions = maparray.filter(
				func(pos):
					return pos.x <= (gridsize - 4) * tilesize and pos.y <= (gridsize - 4) * tilesize)
				location = positions.pick_random()
				tilex = location.x
				tiley = location.y
			if not tiley == 0.0:
				walls.append({ "x": tilex, "y": tiley, "stage": 0 })
				walls.append({ "x": tilex + tilesize, "y": tiley, "stage": 0 })
				walls.append({ "x": tilex + (tilesize * 2), "y": tiley, "stage": 0 })
			if not tilex == 0.0:
				walls.append({ "x": tilex, "y": tiley, "stage": 3 })
				walls.append({ "x": tilex, "y": tiley + tilesize, "stage": 3 })
				walls.append({ "x": tilex, "y": tiley + (tilesize * 2), "stage": 3 })
			if not tilex == gridsize - 1.0:
				walls.append({ "x": tilex + tilesize * 2, "y": tiley, "stage": 1 })
				walls.append({ "x": tilex + tilesize * 2, "y": tiley + tilesize, "stage": 1 })
				walls.append({ "x": tilex + tilesize * 2, "y": tiley + tilesize * 2, "stage": 1 })
			if not tiley == gridsize - 1.0:
				walls.append({ "x": tilex + tilesize * 2, "y": tiley + tilesize * 2, "stage": 2 })
				walls.append({ "x": tilex + tilesize, "y": tiley + tilesize * 2, "stage": 2 })
				walls.append({ "x": tilex, "y": tiley + tilesize * 2, "stage": 2 })
			
			for i in walls:
				wallstage = i.stage
				tilex = i.x
				tiley = i.y
				wall_generate()
				
			
			
			print(location)
			roomsgen += 1
func wall_generate(): #as of now this generates walls around the grid based on conditions set by generate()
	var newwall = wall.instantiate()
	if wallstage == 0:
		if doorpos == 0:
			pass
		else:
			newwall.global_position.y = tiley - (tilesize / 2)
			newwall.scale.x = tilesize
			newwall.scale.y = wallsize
			newwall.global_position.x = tilex
			add_child(newwall)
	elif wallstage == 1:
		if doorpos == 1:
			pass
		else:
			newwall.global_position.x = tilex + (tilesize / 2)
			newwall.scale.y = tilesize 
			newwall.scale.x = wallsize
			newwall.global_position.y = tiley
			add_child(newwall)
	elif wallstage == 2:
		if doorpos == 2:
			pass
		else:
			newwall.global_position.y = tiley + (tilesize / 2)
			newwall.scale.x = tilesize
			newwall.scale.y = wallsize
			newwall.global_position.x = tilex
			add_child(newwall)
	elif wallstage == 3:
		if doorpos == 3:
			pass
		else:
			newwall.global_position.x = tilex - (tilesize / 2)
			newwall.scale.y = tilesize
			newwall.scale.x = wallsize
			newwall.global_position.y = tiley
			add_child(newwall)
