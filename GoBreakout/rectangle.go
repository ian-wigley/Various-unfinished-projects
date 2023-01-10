package main

// rectangle represents a rectangle for collision detection
type rectangle struct {
	x      int
	y      int
	width  int
	height int
}

func (r *rectangle) CheckCollisions() bool {
	if ballRect.x < blockRect.x+blockRect.width && blockRect.x < ballRect.x+ballRect.width && ballRect.y < blockRect.y+blockRect.height {
		return blockRect.y < ballRect.y+ballRect.height
	} else {
		return false
	}
}