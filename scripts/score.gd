extends Node2D

@onready var screen_size = get_viewport().get_visible_rect().size
@onready var score: Label = $ScoreText
@onready var apple: Sprite2D = $Apple


func _ready():
	apple.position = Vector2(screen_size.x - 60, screen_size.y - 40)
	score.position = Vector2(screen_size.x - 40, screen_size.y - 50)


func update_score(snake_length):
	score.text = str(snake_length - 2)


func _draw():
	var score_width = apple.get_rect().size.x + score.get_rect().size.x - 16
	var bg_rect = Rect2(apple.position.x - 20, apple.position.y - 20, score_width, 40)
	draw_rect(bg_rect, Color8(166, 209, 60))
	draw_rect(bg_rect, Color8(56, 74, 12), false)
