extends Node2D

var points = 0

@onready var points_label: Label = $PointsLabel

func _ready() -> void:
	points_label.text = str(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_new_level() -> void:
	points += 1
	points_label.text = str(points)
	# Load and add the new level
	var new_level = load("res://scenes/level.tscn").instantiate()
	add_child(new_level)
	print("sinal recebido")
