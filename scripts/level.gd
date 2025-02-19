extends Node2D

signal level_completed  # Signal to notify higher level when the level is completed

@export var TOWER_SPACING: int = 300
var towers = []
var selected_tower: StockTower = null  # Currently selected tower
var held_box: StockBox = null  # Store removed box
var held_box_position := Vector2(450, 50)  # Position for showing the held box
var objective: String  # Sorting objective: "increase_size", "decrease_size", "increase_price", "decrease_price"
var move_count = -10

@onready var objective_label = $ObjectiveLabel  # A Label node in the scene
@onready var you_win_label: Label = $YouWinLabel
@onready var move_count_label: Label = $MoveCountLabel

func _ready():
	# Randomly select an objective from the four possible sorting methods
	objective = ["increase_size", "decrease_size", "increase_price", "decrease_price"].pick_random()
	you_win_label.visible = false

	# Display the objective
	match objective:
		"increase_size":
			objective_label.text = "Organize por: Tamanho (do menor para o maior)"
		"decrease_size":
			objective_label.text = "Organize por: Tamanho (do maior para o menor)"
		"increase_price":
			objective_label.text = "Organize por: Preço (do mais barato para o mais caro)"
		"decrease_price":
			objective_label.text = "Organize por: Preço (do mais caro para o mais barato)"

	for i in range(3):
		var tower = preload("res://scenes/stock_tower.tscn").instantiate()
		tower.position = Vector2(i * TOWER_SPACING + 275, 500)
		add_child(tower)
		towers.append(tower)

	# Generate stock boxes and distribute them
	for i in range(10):  # Example: 10 boxes
		var price = randi_range(1, 10) * 10
		var width = 40 + randi_range(1, 8) * 20
		var color = Color(randf(), randf(), randf())  # Random color
		var box = preload("res://scenes/stock_box.tscn").instantiate()
		box.setup(price, width, color)

		# Assign to a random tower
		var random_tower = towers[randi_range(0, 2)]
		random_tower.add_box(box)

#func _process(delta: float) -> void:
	#print(self.name)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_A:
			handle_tower_selection(0)  # Left tower
		elif event.keycode == KEY_S:
			handle_tower_selection(1)  # Middle tower
		elif event.keycode == KEY_D:
			handle_tower_selection(2)  # Right tower

func handle_tower_selection(index: int):
	var new_tower = towers[index]

	if held_box:
		new_tower.add_box(held_box)
		held_box = null  # Clear the held box reference
	else:
		held_box = new_tower.remove_top_box()
		if held_box:
			add_child(held_box)  # Ensure it is inside the scene tree
			held_box.position = held_box_position  # Move to display position

func check_win():
	# Check if any tower has 10 boxes and meets the sorting condition
	for tower in towers:
		if tower.boxes.size() == 10:
			match objective:
				"increase_size":
					if tower.increase_size_order():
						declare_win("Tamanho (do menor para o maior)")
				"decrease_size":
					if tower.decrease_size_order():
						declare_win("Tamanho (do maior para o menor)")
				"increase_price":
					if tower.increase_price_order():
						declare_win("Preço (do mais barato para o mais caro)")
				"decrease_price":
					if tower.decrease_price_order():
						declare_win("Preço (do mais caro para o mais barato)")

func declare_win(order_type: String):
	print("YOU WIN! The tower is sorted correctly by " + order_type)
	you_win_label.visible = true
	await get_tree().create_timer(0.8).timeout
	get_parent().create_new_level()
	print("signal emited")
	self.queue_free()
