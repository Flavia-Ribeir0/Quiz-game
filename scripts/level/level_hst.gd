extends Node

enum QuestionType {TEXT, IMAGE}

@export var bd_quiz: Resource
@export var color_right: Color
@export var color_wrong: Color

var buttons := []
var index := 0
var quiz_shuffle := []
var correct := 0
#var wrong := 3
var point := 0
var timer := 10

@onready var question_text := $Question_info/Txt_question
@onready var question_image := $Question_info/Panel/Question_image

func _ready() -> void:
	for _button in $Question_holder.get_children():
		buttons.append(_button)
		
	quiz_shuffle = randomize_array(bd_quiz.bd)
	load_quiz()

func load_quiz() -> void:
	if index >= bd_quiz.bd.size():
		#print("Acabaram as perguntas")
		game_over()
		return
	
	question_text.text = str(quiz_shuffle[index].question_info)
	
	var options = randomize_array(bd_quiz.bd[index].options)
	
	for i in buttons.size():
		buttons[i].text = str(options[i])
		buttons[i].pressed.connect(buttons_answer.bind(buttons[i]))

	match bd_quiz.bd[index].type:
		QuestionType.TEXT:
			$Question_info/Panel.hide()
			
		QuestionType.IMAGE:
			$Question_info/Panel.show()
			question_image.texture = bd_quiz.bd[index].question_image

func buttons_answer(button) -> void:
	if bd_quiz.bd[index].correct == button.text:
		button.modulate = color_right
		correct += 1
		point += 100
		
	else:
		button.modulate = color_wrong
		#wrong -= 1
		point -= 25

	_next_question()
	
func _next_question() -> void:
	timer = 10
	
	await get_tree().create_timer(1).timeout
	for bt in buttons:
		bt.modulate = Color.WHITE
		bt.pressed.disconnect(buttons_answer.bind(bt))
	
	index += 1
	load_quiz()

func randomize_array(array: Array) -> Array:
	randomize()
	var array_temp := array
	array_temp.shuffle()
	return array_temp
	

func game_over() -> void:
	$Game_over.show()
	$Game_over/Alinhamento/Txt_result.text = str(correct, "/", bd_quiz.bd.size())
	#$Game_over/Alinhamento2/Txt_wrong.text = str(wrong,  "/", bd_quiz.bd.size())
	$Game_over/Txt_points.text = str(point)
	$Timer.stop()
	$Txt_timer.hide()


func _on_button_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_back_menu_button_pressed():
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_timer_timeout() -> void:
	$Txt_timer.text = str(timer)
	timer -= 1
	
	if timer < 0:
		_next_question()
