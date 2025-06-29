extends RichTextLabel

func apply_color_based_on_character(color_pj : Color):
	modulate = Color(color_pj.r / 255, color_pj.g / 255, color_pj.b / 255, 1.0)
