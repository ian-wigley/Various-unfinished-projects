package main

import "github.com/hajimehoshi/ebiten/v2"

type Ball struct {
	x         float64
	y         float64
	MinXPos   float64
	MinYPos   float64
	up        bool
	width     int
	height    int
	ballImage *ebiten.Image
}

func (ball *Ball) Init(ballImage *ebiten.Image) {
	ball.x = 300
	ball.y = 660
	ball.ballImage = ballImage
	ball.MinXPos = 0.018
	ball.MinYPos = 0.0235
	ball.up = true
}

func (ball *Ball) Update() {
	// Move ball back into screen space
	if ball.y < ball.MinYPos {
		ball.y = -ball.y
		ball.up = false
		// Move ball back into screen space
		if ball.y < ball.MinYPos {
			ball.y = ball.MinYPos
		}
	}
	if ball.x < ball.MinXPos {
		ball.x = ball.MinXPos
	}
	if ball.x > 1-ball.MinXPos {
		ball.x = 1 - ball.MinXPos
	}
	BallSpeedMultiplicator := 100.0
	moveFactorPerSecond := 0.1 // 0.75 * 0.025 / 1000.0;

	if ball.up {
		ball.y -= moveFactorPerSecond * BallSpeedMultiplicator
	} else {
		ball.y += moveFactorPerSecond * BallSpeedMultiplicator
	}
}

func (ball *Ball) Draw(screen *ebiten.Image) {
	ballPos := &ebiten.DrawImageOptions{}
	ballPos.GeoM.Translate(float64(ball.x), float64(ball.y))
	screen.DrawImage(ball.ballImage, ballPos)
}
