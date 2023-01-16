package main

import "math"

type Vector3 struct {
	X float64
	Y float64
	Z float64
}

func (vector3 *Vector3) Init(x float64, y float64, z float64) {
	vector3.X = x
	vector3.Y = y
	vector3.Z = z
}

func (vector3 *Vector3) Normalize() {
	num := 1 / math.Sqrt(vector3.X*vector3.X + vector3.Y*vector3.Y)
	vector3.X *= num
	vector3.Y *= num
	vector3.Z *= num
}

func (vector3 *Vector3) Zero() {
	vector3.X = 0
	vector3.Y = 0
	vector3.Z = 0
}

func (vector3 *Vector3) Length() float64 {
	return math.Sqrt(vector3.X*vector3.X + vector3.Y*vector3.Y)
}
