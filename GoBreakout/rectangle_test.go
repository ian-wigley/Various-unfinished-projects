package main

import (
	"testing"
)

// Test expects that instantiated rectangles should 
// not intersect as they have no width or height.
func TestBasicIntersects(t *testing.T) {
	rect_one := new(Rectangle)
	rect_two := new(Rectangle)
	result := rect_one.Intersects(rect_two)
	if !result {
		t.Fatalf("Intersection failed")
	}
}

// Test expects that instantiated rectangles should 
// not intersect as they have no width or height.
func TestIntersects(t *testing.T) {
	rect_one := new(Rectangle)
	rect_one.Init(10, 10, 64, 64)
	rect_two := new(Rectangle)
	rect_two.Init(5, 10, 64, 64)
	result := rect_one.Intersects(rect_two)
	if !result {
		t.Fatalf("Intersection failed")
	}
}