extends Node2D

enum Speed {FAST, SLOW}
enum Moves {FEW, ALOT}
enum MissedStacks {NONE, ONCE}

@export var TOWER_SPACING: int = 300
var towers = []
var selected_tower: StockTower = null  # Currently selected tower
var held_box: StockBox = null  # Store removed box
var held_box_position := Vector2(450, 50)  # Position for showing the held box
var objective: String  # Sorting objective: "increase_size", "decrease_size", "increase_price", "decrease_price"
var move_count = -10
var speed_amount = Speed.FAST
var moves_amount = Moves.FEW
var missed_stack = MissedStacks.NONE
var level_results = []

@onready var objective_label = $ObjectiveLabel  # A Label node in the scene
@onready var you_win_label: Label = $YouWinLabel
@onready var move_count_label: Label = $MoveCountLabel
@onready var game_timer = Timer.new()

func _ready():
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
		
	game_timer.wait_time = 20
	game_timer.one_shot = true
	game_timer.timeout.connect(_on_time_over)
	add_child(game_timer)
	game_timer.start()
	
func _process(_delta: float) -> void:
	if move_count > 25:
		moves_amount = Moves.ALOT
	#print(str(moves_amount)+" "+str(speed_amount))
	 
func _on_time_over():
	#print("Time over")
	speed_amount = Speed.SLOW
	# You can add additional logic here (e.g., show game over screen, restart level, etc.)

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
					else:
						missed_stack = MissedStacks.ONCE
				"decrease_size":
					if tower.decrease_size_order():
						declare_win("Tamanho (do maior para o menor)")
					else:
						missed_stack = MissedStacks.ONCE
				"increase_price":
					if tower.increase_price_order():
						declare_win("Preço (do mais barato para o mais caro)")
					else:
						missed_stack = MissedStacks.ONCE
				"decrease_price":
					if tower.decrease_price_order():
						declare_win("Preço (do mais caro para o mais barato)")
					else:
						missed_stack = MissedStacks.ONCE

func declare_win(_order_type: String):
	# print("YOU WIN! The tower is sorted correctly by " + order_type)
	level_results.append(speed_amount)
	level_results.append(moves_amount)
	level_results.append(missed_stack)
	get_parent().process_level_result(level_results)
	
	you_win_label.visible = true
	await get_tree().create_timer(0.8).timeout
	get_parent().create_new_level()
	self.queue_free()
