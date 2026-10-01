extends Node2D
var gridsize = (40)
var maparray = []
var squares = preload("square.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate()
	print(maparray)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#generate()
	pass
	
	
	
	
	
	
	
	
	
	
	
	
func generate():
	for x in range(gridsize):
		for y in range(gridsize):
			var squarematch = squares.instantiate()
			squarematch.global_position = Vector2(x, y)
			add_child(squarematch)
			maparray.append(Vector2(x,y))
