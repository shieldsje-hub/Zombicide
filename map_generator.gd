extends Node2D
#change for settings
var gridsize = (10) #changes side length ex: "gridsize = (3)" would make a 3x3 square
var tilesize = 10.0 #changes how large the map is, should have little to no effect on gameplay
var wallsize = tilesize/5 #how thick the walls are
var roomnumber = int(7) # amount of rooms in the map (2x2 and 3x3)
var furniture_saturation = 4 #generates furniture based on gridsize ex: "gridsize^2/10 creates 10 furniture if gridsize is 10
#don't change
var squares = preload("square.tscn") #link to floor sprite, (1x1, scales with tilesize)
var wall = preload("res://wall.tscn") #link to wall sprite, (1x1, scales with tilesize)
var table = preload("res://table.tscn") # link to table sprite, (1x1, scales with tilesize)
var maparray = [] # tracks all made square coordinates
var wallstage = int(0) #which side is the wall on (0 is top, 1 is right, 2 is bottom, 3 is left
var roomtype = int(1) #0 and 1 for 2x2 and 3x3 respectively
var tiley = float(0.0) #universal tracker for wall, furniture and tile position when created
var tilex = float(0.0) #universal tracker for wall, furniture and tile position when created
var location = Vector2(0.0, 0.0) #used as a baseline for newly generated rooms
var walls: Array = [] #tracks the location and position of all walls before creation
var occupied_tiles = [] #tracks every indoor tile
var furnoccupied_tiles = []# tracks every indoor tile without furniture on it
var walloccupied_tiles = [] # tracks every indoor tile with a wall next to it (basically just excluding 3x3 middles)
var isthisfree = bool(true) #for checking if a tile is available
var realpositions = [] #available positions to spawn a room after deductions
var rooms = []#tracks all rooms and room tile positions
var doortile = [] #tracks every tile position with a door
@onready var debug_camera: Camera2D = $"Debug camera"

func _ready() -> void:
	room_generate()
	generate()
	wall_generate()
	generate_furniture()
	# generates room positions first, then generates floor tiles, followed by walls, and finally furniture
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
func generate(): #this code generates the floor sprites and coordinates for outer walls
	for x in range(gridsize):
		for y in range(gridsize):
			var squarematch = squares.instantiate()
			squarematch.global_position = Vector2(x * tilesize, y * tilesize)
			squarematch.scale = Vector2(tilesize, tilesize)
			squarematch.name = str(int(tilex), "_", int(tiley + tilesize), "Tile")
			for i in occupied_tiles:
				if Vector2(x * tilesize, y * tilesize) == i:
					squarematch.get_child(0).modulate = Color.RED
					
					
			add_child(squarematch)
			tiley = squarematch.global_position.y #- tilesize/2
			tilex = squarematch.global_position.x #- tilesize/2
			if y == 0:
				walls.append({ "x": x * tilesize, "y": y * tilesize, "stage": 0 })
			if x == 0:
				walls.append({ "x": x * tilesize, "y": y * tilesize, "stage": 3 })
			if y == gridsize - 1:
				walls.append({ "x": x * tilesize, "y": y * tilesize, "stage": 2 })
			if x == gridsize - 1:
				walls.append({ "x": x * tilesize, "y": y * tilesize, "stage": 1 })
func room_generate():
	for x in range(gridsize):
		for y in range(gridsize):
			maparray.append(Vector2(x * tilesize, y * tilesize))
	for I in range(roomnumber):
		roomtype = randi_range(0,1) #change this to generate rooms based on set conditions
		if roomtype == 0: #2x2
			var room_tiles = []
			if I == 0:
				tilex = 0.0
				tiley = 0.0
			else:
				var positions = maparray.filter(
				func(pos):
					return pos.x <= (gridsize - 4) * tilesize and pos.y <= (gridsize - 4) * tilesize)
				for a in positions:
					isthisfree = true
					for b in occupied_tiles:
						if a == b:
							isthisfree = false
							break
						if (a + Vector2(tilesize, 0.0)) == b:
							isthisfree = false
							break
						if (a + Vector2(tilesize, tilesize)) == b:
							isthisfree = false
							break
						if (a + Vector2(0.0, tilesize)) == b:
							isthisfree = false
							break
					if isthisfree == true:
						realpositions.append(a)
				if realpositions.size() > 0:
					location = realpositions.pick_random()
					tilex = location.x
					tiley = location.y
				else:
					break
			room_tiles += [Vector2(tilex, tiley)]
			room_tiles += [Vector2(tilex + tilesize, tiley)]
			room_tiles += [Vector2(tilex, tiley + tilesize)]
			room_tiles += [Vector2(tilex + tilesize, tiley + tilesize)]
			rooms.append(room_tiles)
			occupied_tiles += room_tiles
			if not tiley == 0.0:
				walls.append({ "x": tilex, "y": tiley, "stage": 0 })
				walls.append({ "x": tilex + tilesize, "y": tiley, "stage": 0 })
			if not tilex == 0.0:
				walls.append({ "x": tilex, "y": tiley, "stage": 3 })
				walls.append({ "x": tilex, "y": tiley + tilesize, "stage": 3 })
			if not tilex + tilesize == (gridsize * tilesize) - tilesize:
				walls.append({ "x": tilex + tilesize, "y": tiley, "stage": 1 })
				walls.append({ "x": tilex + tilesize, "y": tiley + tilesize, "stage": 1 })
			if not tilex + tilesize == (gridsize * tilesize) - tilesize:
				walls.append({ "x": tilex + tilesize, "y": tiley + tilesize, "stage": 2 })
				walls.append({ "x": tilex, "y": tiley + tilesize, "stage": 2 })
			realpositions.clear()
		elif roomtype == 1: #3x3
			var room_tiles = []
			if I == 0:
				tilex = 0.0
				tiley = 0.0
			else:
				var positions = maparray.filter(
				func(pos):
					return pos.x <= (gridsize - 5) * tilesize and pos.y <= (gridsize - 5) * tilesize)
				for a in positions:
					isthisfree = true
					for b in occupied_tiles:
						if a == b:
							isthisfree = false
							break
						if (a + Vector2(tilesize, 0.0)) == b:
							isthisfree = false
							break
						if (a + Vector2(tilesize * 2, 0.0)) == b:
							isthisfree = false
							break
						if (a + Vector2(0.0, tilesize)) == b:
							isthisfree = false
							break
						if (a + Vector2(tilesize, tilesize)) == b:
							isthisfree = false
							break
						if (a + Vector2(tilesize * 2, tilesize)) == b:
							isthisfree = false
							break
						if (a + Vector2(0.0, tilesize * 2)) == b:
							isthisfree = false
							break
						if (a + Vector2(tilesize, tilesize * 2)) == b:
							isthisfree = false
							break
						if (a + Vector2(tilesize * 2, tilesize * 2)) == b:
							isthisfree = false
							break
					if isthisfree == true:
						realpositions.append(a)
				if realpositions.size() > 0:
					location = realpositions.pick_random()
					tilex = location.x
					tiley = location.y
				else:
					break
			room_tiles += [Vector2(tilex, tiley)]
			room_tiles += [Vector2(tilex + tilesize, tiley)]
			room_tiles += [Vector2(tilex + tilesize * 2, tiley)]
			room_tiles += [Vector2(tilex, tiley + tilesize)]
			room_tiles += [Vector2(tilex + tilesize, tiley + tilesize)]
			room_tiles += [Vector2(tilex + tilesize * 2, tiley + tilesize)]
			room_tiles += [Vector2(tilex, tiley + tilesize * 2)]
			room_tiles += [Vector2(tilex + tilesize, tiley + tilesize * 2)]
			room_tiles += [Vector2(tilex + tilesize * 2, tiley + tilesize * 2)]
			rooms.append(room_tiles)
			occupied_tiles += room_tiles
			if not tiley == 0.0:
				walls.append({ "x": tilex, "y": tiley, "stage": 0 })
				walls.append({ "x": tilex + tilesize, "y": tiley, "stage": 0 })
				walls.append({ "x": tilex + (tilesize * 2), "y": tiley, "stage": 0 })
			if not tilex == 0.0:
				walls.append({ "x": tilex, "y": tiley, "stage": 3 })
				walls.append({ "x": tilex, "y": tiley + tilesize, "stage": 3 })
				walls.append({ "x": tilex, "y": tiley + (tilesize * 2), "stage": 3 })
			if not tilex + tilesize * 2 == (gridsize * tilesize) - tilesize:
				walls.append({ "x": tilex + tilesize * 2, "y": tiley, "stage": 1 })
				walls.append({ "x": tilex + tilesize * 2, "y": tiley + tilesize, "stage": 1 })
				walls.append({ "x": tilex + tilesize * 2, "y": tiley + tilesize * 2, "stage": 1 })
			if not tiley + tilesize * 2 == (gridsize * tilesize) - tilesize:
				walls.append({ "x": tilex + tilesize * 2, "y": tiley + tilesize * 2, "stage": 2 })
				walls.append({ "x": tilex + tilesize, "y": tiley + tilesize * 2, "stage": 2 })
				walls.append({ "x": tilex, "y": tiley + tilesize * 2, "stage": 2 })
				
			realpositions.clear()
func wall_generate():
	var wallcount = {}
	var doors = []
	for w in walls:
		var key = (get_wall_key(w.x, w.y, w.stage))
		if wallcount.has(key):
			wallcount[key] += 1
		else:
			wallcount[key] = 1
	for i in rooms:
		var doortile = i.pick_random()
		if i.size() == 4:
			if doortile == i[0]:
				if randi_range(0 , 1) == 0:
					if not doortile.x == 0.0:
						doors.append({ "x": doortile.x, "y": doortile.y, "stage": 3 })
				else:
					if not doortile.y == 0.0:
						doors.append({ "x": doortile.x, "y": doortile.y, "stage": 0 })
			if doortile == i[1]:
				if randi_range(0 , 1) == 0:
					if not doortile.y == 0.0:
						doors.append({ "x": doortile.x, "y": doortile.y, "stage": 0 })
				else:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 1 })
			if doortile == i[2]:
				if randi_range(0 , 1) == 0:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 2 })
				else:
					if not doortile.x == 0.0:
						doors.append({ "x": doortile.x, "y": doortile.y, "stage": 3 })
			if doortile == i[3]:
				if randi_range(0 , 1) == 0:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 1 })
				else:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 2 })
		elif i.size() == 9:
			if doortile == i[0]:
				if randi_range(0 , 1) == 0:
					if not doortile.x == 0.0:
						if not doortile.x == 0.0:
							doors.append({ "x": doortile.x, "y": doortile.y, "stage": 3 })
				else:
					if not doortile.y == 0.0:
						doors.append({ "x": doortile.x, "y": doortile.y, "stage": 0 })
			if doortile == i[1]:
				if not doortile.y == 0.0:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 0 })
			if doortile == i[2]:
				if randi_range(0 , 1) == 0:
					if not doortile.y == 0.0:
						doors.append({ "x": doortile.x, "y": doortile.y, "stage": 0 })
				else:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 1 })
			if doortile == i[3]:
				if not doortile.x == 0.0:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 3 })
			if doortile == i[4]:
				pass
			if doortile == i[5]:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 1 })
			if doortile == i[6]:
				if randi_range(0 , 1) == 0:
					if not doortile.x == 0.0:
						doors.append({ "x": doortile.x, "y": doortile.y, "stage": 3 })
				else:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 2 })
			if doortile == i[7]:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 2 })
			if doortile == i[8]:
				if randi_range(0 , 1) == 0:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 1 })
				else:
					doors.append({ "x": doortile.x, "y": doortile.y, "stage": 2 })
	for i in walls:
		var key = get_wall_key(i.x, i.y, i.stage)

		if wallcount[key] > 1:
			continue 
		wallstage = i.stage
		tilex = i.x 
		tiley = i.y 
		var newwall = wall.instantiate()
		if doors.has(i):
			newwall.get_child(1).self_modulate = Color.YELLOW
			doortile.append(Vector2(i.x, i.y)) 
		if wallstage == 0:
			
				newwall.global_position.y = tiley - (tilesize / 2)
				newwall.scale.x = tilesize
				newwall.scale.y = wallsize
				newwall.global_position.x = tilex
				newwall.name = str(int(tilex), "_", int(tiley), "_", 0 , "Wall")
				print(int(tiley), "_", int(tilex), "_", 0 , "Wall")
				add_child(newwall)
		elif wallstage == 1:
			
				newwall.global_position.x = tilex + (tilesize / 2)
				newwall.scale.y = tilesize 
				newwall.scale.x = wallsize
				newwall.global_position.y = tiley
				newwall.name = str(int(tilex), "_", int(tiley), "_", 1 , "Wall")
				add_child(newwall)
		elif wallstage == 2:
			
				newwall.global_position.y = tiley + (tilesize / 2)
				newwall.scale.x = tilesize
				newwall.scale.y = wallsize
				newwall.global_position.x = tilex
				newwall.name = str(int(tilex), "_", int(tiley), "_", 2 , "Wall")
				add_child(newwall)
		elif wallstage == 3:
			
				newwall.global_position.x = tilex - (tilesize / 2)
				newwall.scale.y = tilesize
				newwall.scale.x = wallsize
				newwall.global_position.y = tiley
				newwall.name = str(int(tilex), "_", int(tiley), "_", 3 , "Wall")
				add_child(newwall)
func get_wall_key(x, y, stage):
	
	match stage:
		0: # top
			return "H_%s_%s" % [x, y - tilesize / 2]
		1: # right
			return "V_%s_%s" % [x + tilesize / 2, y]
		2: # bottom
			return "H_%s_%s" % [x, y + tilesize / 2]
		3: # left
			return "V_%s_%s" % [x - tilesize / 2, y]
	return ""
func generate_furniture():
	furnoccupied_tiles = occupied_tiles
	for i in furnoccupied_tiles:
		if doortile.has(i):
			furnoccupied_tiles.erase(i)
	for i in range(furniture_saturation):
		var randpos = furnoccupied_tiles.pick_random()
		if randi_range(0,1) == 0:
			var newtable = table.instantiate()
			newtable.global_position = randpos
			furnoccupied_tiles.erase(randpos)
			newtable.scale = Vector2(tilesize * 0.6, tilesize * 0.6)
			add_child(newtable)
		else:
			pass
			#add wardrobe/wall locked furniture
		
