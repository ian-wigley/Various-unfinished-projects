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
	"math/rand"
	"time"

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
	ballRect          *Rectangle
	blockRect         *Rectangle
	b                 *Ball

	terminated = errors.New("terminated")
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

	b = new(Ball)
	b.Init(ball)

	ballRect = new(Rectangle)
	ballRect.x = ballX
	ballRect.y = ballY
	ballRect.width = ball.Bounds().Dx()
	ballRect.height = ball.Bounds().Dy()

	blockRect = new(Rectangle)
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

type Game struct {
	rectangle         *Rectangle
	pressSpaceToStart bool
}

// region Start and stop ball
// / <summary>
// / Start new ball at the beginning of each game and when a ball is lost.
// / </summary>
func StartNewBall() {
	// Randomize direction, but always go up
	ballSpeedVector := new(Vector2)
	rand.Seed(time.Now().UnixNano())
	randId := randFloats(-1, 1, 2)
	//ballSpeedVector.Init(RandomHelper.GetRandomFloat(-1, +1), -1)
	ballSpeedVector.Init(randId[0], randId[1])
	//new Vector2(RandomHelper.GetRandomFloat(-1, +1), -1);
	ballSpeedVector.Normalize()
	// Make sure game is started now
	if score < 0 {
		score = 0
	}
	// If we lost the game and restarted, reset score!
	if lostGame {
		// Game over, reset to level 0
		level = 0
		score = 0
		lostGame = false
		//StartLevel()
	} // if
	// Clear message
	pressSpaceToStart = false
} // StartNewBall()

func randFloats(min, max float64, n int) []float64 {
	res := make([]float64, 2)
	for i := range res {
		res[i] = min + rand.Float64()*(max-min)
	}
	return res
}

// / <summary>
// / Stop ball for menu and when game is over.
// / </summary>
func StopBall() {
	ballSpeedVector := new(Vector2)
	ballSpeedVector.Init(0, 0)
	pressSpaceToStart = true
} // StopBall

func (game *Game) Update() error {
	shouldReturn, returnValue := CheckKeypress(game)
	if shouldReturn {
		return returnValue
	}

	if !game.pressSpaceToStart {
		b.Update()

		// Check collisions
		CheckBallCollisions(moveFactorPerSecond);

		// Update ball position and bounce off the borders
		ballPosition += ballSpeedVector * moveFactorPerSecond * BallSpeedMultiplicator;

		// Ball lost?
		if (ballPosition.Y > 0.985) {
			// Play sound
			// soundBank.PlayCue("PongBallLost");
			// Show lost message, reset is done above in StartNewBall!
			lostGame = true;
			pressSpaceToStart = true;
		} // if

		// Check if all blocks are killed and if we won this level
		var allBlocksKilled = true;
		for (y := 0; y < NumOfRows; y++) {
			for (int x = 0; x < NumOfColumns; x++) {
				if (blocks[x, y]) {
					allBlocksKilled = false;
					break;
				} // for for if
				}
			}

		// We won, start next level
		if (allBlocksKilled == true) {
			// Play sound
			// soundBank.PlayCue("BreakoutVictory");
			lostGame = false;
			level++;
			StartLevel();
		} // if


	}

	return nil
}

func CheckKeypress(game *Game) (bool, error) {
	if ebiten.IsKeyPressed(ebiten.KeyArrowRight) {
		batX += 2
	}
	if ebiten.IsKeyPressed(ebiten.KeyArrowLeft) {
		batX -= 2
	}
	if game.pressSpaceToStart {
		if ebiten.IsKeyPressed(ebiten.KeySpace) {
			StartNewBall()
		}
	}
	if ebiten.IsKeyPressed(ebiten.KeyEscape) {
		return true, terminated
	}
	return false, nil
}

func (game *Game) Draw(screen *ebiten.Image) {
	backGroundPos := &ebiten.DrawImageOptions{}
	backGroundPos.GeoM.Scale(2.0, 2.0)
	screen.DrawImage(background, backGroundPos)

	if game.rectangle.CheckCollisions() {
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

	b.Draw(screen)

	// ballPos := &ebiten.DrawImageOptions{}
	// ballPos.GeoM.Translate(float64(ballX), float64(ballY))
	// screen.DrawImage(ball, ballPos)

	score_str := fmt.Sprintf("Score: %d", score)
	text.Draw(screen, score_str, mplusNormalFont, 100, 100, color.White)
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int) {
	return width, height
}
