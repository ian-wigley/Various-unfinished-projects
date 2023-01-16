package main

import "math"

type Vector2 struct {
	X float64
	Y float64
}

func (vector2 *Vector2) Init(x float64, y float64) {
	vector2.X = x
	vector2.Y = y
}

func (vector2 *Vector2) Normalize() {
	num := 1 / math.Sqrt(vector2.X*vector2.X+vector2.Y*vector2.Y)
	vector2.X *= num
	vector2.Y *= num
}

func (vector2 *Vector2) Zero() {
	vector2.X = 0
	vector2.Y = 0
}

func (vector2 *Vector2) Length() float64 {
	return math.Sqrt(vector2.X*vector2.X + vector2.Y*vector2.Y)
}
