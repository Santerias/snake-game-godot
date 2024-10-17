extends Node

@onready var tilemap: TileMap = $TileMap
@onready var crunch_sound: AudioStreamPlayer = $CrunchSound

const SNAKE = 0
const APPLE = 1

var apple_pos
var snake_body = [Vector2(5, 10), Vector2(4,10), Vector2(3, 10)]
var snake_direction = Vector2(1, 0)
var add_apple = false


func _ready() -> void:
	apple_pos = place_apple()


func _process(delta: float) -> void:
	check_game_over()
	if apple_pos in snake_body:
		apple_pos = place_apple()


func place_apple():
	randomize()
	var x = randi() % 20
	var y = randi() % 20
	return Vector2(x, y)


func draw_apple():
	tilemap.set_cell(0, Vector2i(apple_pos.x, apple_pos.y), APPLE, Vector2i(0, 0))


func draw_snake():
	#for block in snake_body:
		#tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(7, 0))
	
	for block_index in snake_body.size():
		var block = snake_body[block_index]
		
		if block_index == 0:
			var head_direction = relation2(snake_body[0], snake_body[1])
			if head_direction == "right":
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(2, 0), TileSetAtlasSource.TRANSFORM_FLIP_H)
			if head_direction == "left":
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(2, 0), 0)
			if head_direction == "top":
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(3, 0), 0)
			if head_direction == "bottom":
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(3, 0), TileSetAtlasSource.TRANSFORM_FLIP_V)
		elif block_index == snake_body.size() - 1:
			var tail_direction = relation2(snake_body[-1], snake_body[-2])
			if tail_direction == "right":
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(0, 0), 0)
			if tail_direction == "left":
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(0, 0), TileSetAtlasSource.TRANSFORM_FLIP_H)
			if tail_direction == "top":
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(0, 1), TileSetAtlasSource.TRANSFORM_FLIP_V)
			if tail_direction == "bottom":
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(0, 1), 0)
		
		else:
			var previous_block = snake_body[block_index + 1] - block
			var next_block = snake_body[block_index - 1] - block
		
			if previous_block.x == next_block.x:
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(4, 1))
			elif previous_block.y == next_block.y:
				tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(4, 0))
			else:
				#tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(7, 0))
				if previous_block.x == -1 and next_block.y == -1 or next_block.x == -1 and previous_block.y == -1:
					tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(5, 0), TileSetAtlasSource.TRANSFORM_FLIP_H | TileSetAtlasSource.TRANSFORM_FLIP_V)
				if previous_block.x == -1 and next_block.y == 1 or next_block.x == -1 and previous_block.y == 1:
					tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(5, 0), TileSetAtlasSource.TRANSFORM_FLIP_H)
				if previous_block.x == 1 and next_block.y == -1 or next_block.x == 1 and previous_block.y == -1:
					tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(5, 0), TileSetAtlasSource.TRANSFORM_FLIP_V)
				if previous_block.x == 1 and next_block.y == 1 or next_block.x == 1 and previous_block.y == 1:
					tilemap.set_cell(0, Vector2i(block.x, block.y), SNAKE, Vector2i(5, 0), 0)


func relation2(first_block: Vector2, second_block: Vector2):
	var block_relation = second_block - first_block
	if block_relation == Vector2(-1, 0): return "left"
	if block_relation == Vector2(1, 0): return "right"
	if block_relation == Vector2(0, 1): return "bottom"
	if block_relation == Vector2(0, -1): return "top"


func move_snake():
	if add_apple:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 0)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body = body_copy
		add_apple = false
	else:
		delete_tiles(SNAKE)
		var body_copy = snake_body.slice(0, snake_body.size() - 1)
		var new_head = body_copy[0] + snake_direction
		body_copy.insert(0, new_head)
		snake_body = body_copy


func delete_tiles(id: int):
	var cells = tilemap.get_used_cells_by_id(0, id)
	for cell in cells:
		tilemap.set_cell(0, Vector2i(cell.x, cell.y), -1)


func check_apple_eaten():
	if apple_pos == snake_body[0]:
		apple_pos = place_apple()
		add_apple = true
		get_tree().call_group("ScoreGroup", "update_score", snake_body.size())
		crunch_sound.play()

func check_game_over():
	var head = snake_body[0]
	# snake leaves screen
	if head.x > 20 or head.x < 0 or head.y < 0 or head.y > 20:
		reset()
	
	# snake overlapping
	for block in snake_body.slice(1, snake_body.size() - 0):
		if block == head:
			reset()


func reset():
	snake_body = [Vector2(5, 10), Vector2(4,10), Vector2(3, 10)]
	snake_direction = Vector2(1, 0)
	get_tree().call_group("ScoreGroup", "update_score", 2)


func _input(event):
	if Input.is_action_just_pressed("move_up"):
		if not snake_direction == Vector2(0, 1):
			snake_direction = Vector2(0, -1)
	if Input.is_action_just_pressed("move_down"):
		if not snake_direction == Vector2(0, -1):
			snake_direction = Vector2(0, 1)
	if Input.is_action_just_pressed("move_right"):
		if not snake_direction == Vector2(-1, 0):
			snake_direction = Vector2(1, 0)
	if Input.is_action_just_pressed("move_left"):
		if not snake_direction == Vector2(1, 0):
			snake_direction = Vector2(-1, 0)


func _on_snake_tick_timeout() -> void:
	move_snake()
	draw_apple()
	draw_snake()
	check_apple_eaten()
