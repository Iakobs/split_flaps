@tool
@icon("res://addons/split_flaps/SplitFlapLabel.svg")
class_name SplitFlapLabel extends HBoxContainer
## A control that display texts like a split flap board.
##
## It iterates through a list of characters until it reaches the target character.
## You can configure if the board is split by letter or not, the font, size, colour, etc.

signal animation_finished

const DEFAULT_FLAP_LIST: PackedStringArray = []
const DEFAULT_BACKGROUND_COLOR := Color(0.2, 0.2, 0.2, 1.0)

@export_category("Display")
@export_group("Label")
## The text to display in the split flap board.
@export var line: String:
	set(value):
		line = value
		if Engine.is_editor_hint():
			_update_letters()

## The label settings where you can adjust the font, color, size, etc.
@export var label_settings: LabelSettings:
	set(value):
		label_settings = value
		if Engine.is_editor_hint() and value:
			for letter: SplitFlapLetter in _letters:
				letter.custom_label_settings = label_settings

## A custom list of characters to flap through. If you leave it empty, it will use the font's allowed characters.[br]
## [br]
## If a character in the [member line] variable is not in this list, it will be displayed after
## rolling all the characters in it.
@export var flap_list := DEFAULT_FLAP_LIST:
	set(value):
		flap_list = value
		if Engine.is_editor_hint() and value:
			for letter: SplitFlapLetter in _letters:
				letter.flap_list = flap_list

@export_group("Background")
## The color for the background of the split flap board.
@export var background_color := DEFAULT_BACKGROUND_COLOR:
	set(value):
		background_color = value
		if Engine.is_editor_hint() and value:
			for letter: SplitFlapLetter in _letters:
				letter.background_color = background_color

## The scale of the background image.
@export var background_scale := Vector2.ONE:
	set(value):
		background_scale = value
		if Engine.is_editor_hint() and value:
			for letter: SplitFlapLetter in _letters:
				letter.background_scale = background_scale

@export_category("Behaviour")
## If [code]true[/code], every letter in the [member line] variable will be displayed individually.
## Otherwise, the whole text will be displayed in a single split flap board.[br]
## [br]
## Set this to [code]false[/code] and add complete words to the [member flap_list] variable 
## to flap through a list of words, instead of letters.
@export var single_letters := true:
	set(value):
		single_letters = value
		if Engine.is_editor_hint():
			_update_letters()

@export_group("Label")
## The delay between every letter to start flapping.
@export var start_delay := 0.1
## If [code]true[/code], the [member start_delay] will be a random number, close to the value defined.
## Otherwise, it will be the exact [member start_delay] value.
@export var start_delay_randomness := true

@export_group("Letters")
## The delay between every flap on a single letter.
@export var letter_delay := 0.1
## If [code]true[/code], the [member letter_delay] will be a random number, close to the value defined.
## Otherwise, it will be the exact [member letter_delay] value.
@export var letter_delay_randomness := true

var _letter_scene := preload("res://addons/split_flaps/split_flap_letter.tscn")
var _letters: Array[SplitFlapLetter] = []
var _counter := 0

func _ready() -> void:
	_update_letters()

func animate() -> void:
	_counter = 0
	
	for letter_scene: SplitFlapLetter in _letters:
		letter_scene.animate_letter()
		#letter_scene.letter_animation_finished.connect(func():
			#_counter -= 1
			#if _counter == 0:
				#animation_finished.emit()
		#)
		var delay := start_delay if not start_delay_randomness else randf_range(
			start_delay * 0.75,
			start_delay * 0.25
		)
		await get_tree().create_timer(delay).timeout

func cancel_animation() -> void:
	for letter_scene: SplitFlapLetter in _letters:
		letter_scene.cancel_animation()

func _update_letters() -> void:
	_letters.clear()
	for child in get_children():
		remove_child(child)
		child.queue_free()
	
	if single_letters:
		for character: String in line:
			_add_letter(character)
	else:
		_add_letter(line)

func _add_letter(new_text: String) -> void:
	var letter_scene := _letter_scene.instantiate() as SplitFlapLetter
	add_child(letter_scene)
	letter_scene.set_new_text(new_text)
	letter_scene.letter_delay = letter_delay
	letter_scene.letter_delay_randomness = letter_delay_randomness
	letter_scene.background_color = background_color
	letter_scene.background_scale = background_scale
	if label_settings:
		letter_scene.custom_label_settings = label_settings
	if not flap_list.is_empty():
		letter_scene.flap_list = flap_list
	
	letter_scene.letter_animation_finished.connect(func():
		_counter += 1
		if _counter == _letters.size():
			animation_finished.emit()
	)
	
	_letters.append(letter_scene)
