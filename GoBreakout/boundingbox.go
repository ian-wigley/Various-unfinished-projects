package main

type BoundingBox struct {
	X   float64
	Y   float64
	Min *Vector3
	Max *Vector3
}

func (boundingBox *BoundingBox) Init(min Vector3, max Vector3) {
	boundingBox.Min = &min
	boundingBox.Max = &max
}

func (boundingBox *BoundingBox) Intersects(box *BoundingBox) bool {
	if (boundingBox.Max.X >= box.Min.X) && (boundingBox.Min.X <= box.Max.X) {
		if (boundingBox.Max.Y < box.Min.Y) || (boundingBox.Min.Y > box.Max.Y) {
			return false
		}
		return (boundingBox.Max.Z >= box.Min.Z) && (boundingBox.Min.Z <= box.Max.Z)
	}
	return false
}
