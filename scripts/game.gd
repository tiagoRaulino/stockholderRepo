extends Node2D

var current_level = 0
var objectives_manager: ObjectivesManager
var scoring_tree
var total_score: int = 0
@onready var current_level_label: Label = $CurrentLevelLabel
@onready var scoring_label: Label = $ScoringLabel

func _ready() -> void:
	current_level_label.text = str(0)
	objectives_manager = ObjectivesManager.new()
	
	# Criar apenas 5 objetivos no início
	for i in range(5):
		create_objective()
	#objectives_manager.print_objectives()
	create_new_level()
	var ScoringTreeScript = load("res://scripts/scoring_tree_node.gd")  # Ensure this is the correct path
	scoring_tree = ScoringTreeScript.new()

func create_new_level() -> void:
	current_level += 1
	current_level_label.text = str(current_level)
	
	if objectives_manager.head != null:
		var new_level = load("res://scenes/level.tscn").instantiate()
		new_level.objective = objectives_manager.head.get_objective()  # Passa o objetivo correto
		objectives_manager.head = objectives_manager.head.next  # Avança na lista
		
		# Substituir o objetivo consumido para manter um total de 5
		create_objective()
		
		#objectives_manager.print_objectives()
		add_child(new_level)

func create_objective() -> void:
	var objective_type = ["increase_size", "decrease_size", "increase_price", "decrease_price"].pick_random()
	var new_objective = Objective.new(objective_type)
	objectives_manager.add_objective(new_objective)

class Objective:
	var next: Objective = null
	var previous: Objective = null
	var level_objective: String

	func _init(obj: String) -> void:
		self.level_objective = obj
	
	func get_objective() -> String:
		return level_objective

class ObjectivesManager:
	var head: Objective = null
	var tail: Objective = null
	
	func add_objective(new_objective: Objective) -> void:
		if head == null:
			head = new_objective
			tail = new_objective
		else:
			tail.next = new_objective
			new_objective.previous = tail
			tail = new_objective

	func print_objectives() -> void:
		var current = head
		print("Lista de Objetivos:")
		while current != null:
			print("Objetivo:", current.get_objective())
			current = current.next
		print("----------------------------")
		
func process_level_result(LevelStates: Array):
	var level_score = scoring_tree.get_score(LevelStates)
	total_score += level_score
	scoring_label.text = str(total_score)
	print(LevelStates)
	print("Level Score:", level_score)
	print("Total Score: ", total_score)
	
