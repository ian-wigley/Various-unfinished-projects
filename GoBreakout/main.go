package main

import (
	_ "image/png"
	"log"

	"github.com/hajimehoshi/ebiten/v2"
)

const width = 1024
const height = 768

func main() {
	ebiten.SetWindowSize(width, height)
	ebiten.SetWindowTitle("Go! Breakout")
	if err := ebiten.RunGame(&Game{}); err != nil {
		if err == terminated {
			return
		}
		log.Fatal(err)
	}
}
