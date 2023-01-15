package main

type Vector2 struct {
	x      float64
	y      float64
}

func (vector2 *Vector2) Init(x float64, y float64) {
	vector2.x = x
	vector2.y = y
}

func (vector2 *Vector2) Normalize() {
	// Todo - add code
}