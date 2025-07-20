extends TextureRect
# I tried making a satisfying start button

func _pressed():
	$AudioStreamPlayer.play()
