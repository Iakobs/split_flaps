@tool
class_name SplitFlapLetter extends Label

signal letter_animation_finished

@onready var flap: AudioStreamPlayer = %Flap

var custom_label_settings: LabelSettings:
	set(value):
		custom_label_settings = value
		label_settings = custom_label_settings
		_recalculate_size()
var flap_list: PackedStringArray = []:
	set(value):
		flap_list = value
		_recalculate_size()
var letter_delay := 0.1
var letter_delay_randomness := true
var background_color: Color:
	set(value):
		background_color = value
		var stylebox := get_theme_stylebox(&"normal") as StyleBoxTexture
		stylebox.modulate_color = background_color
var background_scale := Vector2.ONE:
	set(value):
		background_scale = value
		_recalculate_size()

var _vertical_position := 0.0
var _animation_cancelled := false

func _ready() -> void:
	if not Engine.is_editor_hint():
		visible_ratio = 0.0

func set_new_text(value: String) -> void:
	_recalculate_size()
	text = value.to_upper()

func animate_letter() -> void:
	visible_ratio = 1.0
	var font := label_settings.font if label_settings and label_settings.font else get_theme_default_font()
	var supported_chars := font.get_supported_chars().split()
	var final_flap_list := flap_list if not flap_list.is_empty() else supported_chars
	var original_text := text
	
	for supported_char: String in final_flap_list:
		if _animation_cancelled:
			_animation_cancelled = false
			break
		
		var upper_supported_char := supported_char.to_upper()
		if upper_supported_char == original_text:
			break
		flap.play()
		_shake()
		text = upper_supported_char
		var delay := letter_delay if not letter_delay_randomness else randf_range(
			letter_delay * 0.75,
			letter_delay * 0.25
		)
		await get_tree().create_timer(delay).timeout
	
	_text_found(original_text)

func cancel_animation() -> void:
	_animation_cancelled = true

func _text_found(original_text: String) -> void:
	text = original_text
	flap.play()
	_shake()
	await get_tree().process_frame
	letter_animation_finished.emit()

func _shake() -> void:
	var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(
		self,
		"position:y",
		_vertical_position,
		0.1
	).from(_vertical_position + 7.5)

func _recalculate_size() -> void:
	var widest_text := "W" # W is the widest letter
		
	if not flap_list.is_empty(): # If not in single letter mode, the width is calculated based on the widest element of the flap list
		for element: String in flap_list:
			if element.length() > widest_text.length():
				widest_text = element
	var font := label_settings.font if label_settings and label_settings.font else get_theme_default_font()
	var font_size := label_settings.font_size if label_settings and label_settings.font_size else get_theme_font_size(&"font_size")
	var string_size = font.get_string_size(
		widest_text,
		horizontal_alignment,
		-1,
		font_size
	)
	var stylebox := get_theme_stylebox(&"normal") as StyleBoxTexture
	var horizontal_margin := stylebox.texture_margin_left + stylebox.texture_margin_left
	var width := string_size.x + horizontal_margin as float
	custom_minimum_size = Vector2(width, string_size.y) * background_scale
