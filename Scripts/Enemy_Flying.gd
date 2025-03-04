extends Enemy

func HitByBubble():
	super.HitByBubble()
	$"..".canMove = false

func EscapeFromBubble():
	$"..".canMove = true
	super.EscapeFromBubble()
