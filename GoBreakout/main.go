package main

//https://github.com/jarreed0/wordle/blob/main/go/wordle.go
//https://golangprojectstructure.com/creating-cool-games-with-ebiten-in-go/

//https://ebiten.org/documents/webassembly.html
//GOOS=js GOARCH=wasm go build -o main.wasm

import (
	"errors"
	"fmt"
	"image"
	"image/color"
	_ "image/png"
	"log"
	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/examples/resources/fonts"
	"github.com/hajimehoshi/ebiten/v2/text"
	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
)

var (
	background        *ebiten.Image
	gameImages        *ebiten.Image
	bat               *ebiten.Image
	ball              *ebiten.Image
	block             *ebiten.Image
	win               *ebiten.Image
	lost              *ebiten.Image
	width             = 1024
	height            = 768
	batX              = 0
	batY              = 700
	ballX             = 0
	ballY             = 660
	level             = 0
	score             = 0
	pressSpaceToStart = true
	lostGame          = false
	mplusNormalFont   font.Face
	fontSize          = 20
	ballRect          *rectangle
	blockRect         *rectangle
	terminated        = errors.New("terminated")
)

func init() {
	var err error
	background, _, err = ebitenutil.NewImageFromFile("SpaceBackground.png")
	if err != nil {
		log.Fatal(err)
	}
	gameImages, _, err = ebitenutil.NewImageFromFile("BreakoutGame.png")
	if err != nil {
		log.Fatal(err)
	}

	ball = gameImages.SubImage(image.Rect(1, 1, 38, 38)).(*ebiten.Image)
	bat = gameImages.SubImage(image.Rect(39, 1, 131, 25)).(*ebiten.Image)
	block = gameImages.SubImage(image.Rect(137, 1, 197, 27)).(*ebiten.Image)
	win = gameImages.SubImage(image.Rect(1, 40, 92, 60)).(*ebiten.Image)
	lost = gameImages.SubImage(image.Rect(106, 40, 200, 60)).(*ebiten.Image)

	ballRect = new(rectangle)
	ballRect.x = ballX
	ballRect.y = ballY
	ballRect.width = ball.Bounds().Dx()
	ballRect.height = ball.Bounds().Dy()

	blockRect = new(rectangle)
	blockRect.width = 100
	blockRect.height = 100

	tt, err := opentype.Parse(fonts.MPlus1pRegular_ttf)
	if err != nil {
		log.Fatal(err)
	}
	mplusNormalFont, err = opentype.NewFace(tt, &opentype.FaceOptions{
		Size:    float64(fontSize),
		DPI:     72,
		Hinting: font.HintingFull,
	})
	if err != nil {
		log.Fatal(err)
	}
}

// player represents the current airship's position.
type player struct {
	// x16, y16 represents the position in XY plane in fixed float format.
	// The fractional part has 16 bits of precision.
	x16 int
	y16 int

	// angle represents the player's angle in XY plane.
	// angle takes an integer value in [0, maxAngle).
	angle int

	// lean represents the player's leaning.
	// lean takes an integer value in [-maxLean, maxLean].
	lean int
}

type Game struct {
	rectangle *rectangle
}

func (g *Game) Update() error {
	if ebiten.IsKeyPressed(ebiten.KeyArrowRight) {
		batX += 2
	}
	if ebiten.IsKeyPressed(ebiten.KeyArrowLeft) {
		batX -= 2
	}
	if ebiten.IsKeyPressed(ebiten.KeySpace) {
		ballY -= 10
		ballRect.y -= 10
	}
	if ebiten.IsKeyPressed(ebiten.KeyEscape) {
		return terminated
	}
	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	backGroundPos := &ebiten.DrawImageOptions{}
	backGroundPos.GeoM.Scale(2.0, 2.0)
	screen.DrawImage(background, backGroundPos)

	if g.rectangle.CheckCollisions() {
		ebitenutil.DrawRect(screen, float64(0), 0, 100, 100, color.White)
	} else {
		ebitenutil.DrawRect(screen, float64(0), 0, 100, 100, color.Gray16{0xa000})
	}

	for a := 0; a < 10; a++ {
		blockPos := &ebiten.DrawImageOptions{}
		blockPos.GeoM.Translate(100*float64(a), 100)
		screen.DrawImage(block, blockPos)
	}

	batPos := &ebiten.DrawImageOptions{}
	batPos.GeoM.Translate(float64(batX), float64(batY))
	screen.DrawImage(bat, batPos)

	ballPos := &ebiten.DrawImageOptions{}
	ballPos.GeoM.Translate(float64(ballX), float64(ballY))
	screen.DrawImage(ball, ballPos)

	score_str:=fmt.Sprintf("Score: %d", score)
	text.Draw(screen, score_str, mplusNormalFont, 100, 100, color.White)
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int) {
	return width, height
}

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
