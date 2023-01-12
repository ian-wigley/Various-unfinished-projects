package main

// Rectangle represents a Rectangle for collision detection
type Rectangle struct {
	x      int
	y      int
	width  int
	height int
}

func (rectangle *Rectangle) Init(x int, y int, width int, height int) {
	rectangle.x = x
	rectangle.y = y
	rectangle.width = width
	rectangle.height = height
}

func (rectangle *Rectangle) CheckCollisions() bool {
	if ballRect.x < blockRect.x+blockRect.width && blockRect.x < ballRect.x+ballRect.width && ballRect.y < blockRect.y+blockRect.height {
		return blockRect.y < ballRect.y+ballRect.height
	} else {
		return false
	}
}

func (rectangle *Rectangle) Intersects(otherRect *Rectangle) bool {
	if rectangle.x < otherRect.x+otherRect.width &&
		otherRect.x < rectangle.x+rectangle.width &&
		rectangle.y < otherRect.y+otherRect.height {
		return otherRect.y < rectangle.y+rectangle.height
	} else {
		return false
	}
}
