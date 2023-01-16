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
	"math"
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
	background *ebiten.Image
	gameImages *ebiten.Image
	bat        *ebiten.Image
	ball       *ebiten.Image
	block      *ebiten.Image
	win        *ebiten.Image
	lost       *ebiten.Image
	batX       = 0
	batY       = 700
	ballX      = 0
	ballY      = 660

	mplusNormalFont font.Face
	fontSize        = 20
	ballRect        *Rectangle
	blockRect       *Rectangle
	b               *Ball

	GamePaddleRect  *Rectangle
	GameBallRect    *Rectangle
	GameBlockRect   *Rectangle
	GameYouWonRect  *Rectangle
	GameYouLostRect *Rectangle
	// paddlePosition = 0.5
	// ballPosition    *Vector2
	// ballSpeedVector *Vector2
	// level             = 0
	// score             = 0
	// pressSpaceToStart = true

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
	rectangle *Rectangle

	paddlePosition    float64
	ballPosition      *Vector2
	ballSpeedVector   *Vector2
	level             int
	score             int
	pressSpaceToStart bool
	lostGame          bool
	blocks            [][]bool
	blockBoxes 		  [][]BoundingBox
}

const BallSpeedMultiplicator float64 = 0.85
const NumOfColumns int = 14
const NumOfRows int = 12

// region Start and stop ball
// / <summary>
// / Start new ball at the beginning of each game and when a ball is lost.
// / </summary>
func (game *Game) StartNewBall() {
	// Randomize direction, but always go up
	ballSpeedVector := new(Vector2)
	rand.Seed(time.Now().UnixNano())
	randId := randFloats(-1, 1, 2)
	//ballSpeedVector.Init(RandomHelper.GetRandomFloat(-1, +1), -1)
	ballSpeedVector.Init(randId[0], randId[1])
	//new Vector2(RandomHelper.GetRandomFloat(-1, +1), -1);
	ballSpeedVector.Normalize()
	// Make sure game is started now
	if game.score < 0 {
		game.score = 0
	}
	// If we lost the game and restarted, reset score!
	if game.lostGame {
		// Game over, reset to level 0
		game.level = 0
		game.score = 0
		game.lostGame = false
		//StartLevel()
	} // if
	// Clear message
	game.pressSpaceToStart = false
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
func (game *Game) StopBall() {
	ballSpeedVector := new(Vector2)
	ballSpeedVector.Init(0, 0)
	game.pressSpaceToStart = true
} // StopBall

func (game *Game) Update() error {

	// Move half way across the screen each second
	moveFactorPerSecond := 0.0125;

	shouldReturn, returnValue := CheckKeypress(game)
	if shouldReturn {
		return returnValue
	}

	if !game.pressSpaceToStart {
		b.Update()

		// Check collisions
		game.CheckBallCollisions(moveFactorPerSecond);

		// // Update ball position and bounce off the borders
		// ballPosition += ballSpeedVector * moveFactorPerSecond * BallSpeedMultiplicator;

		// // Ball lost?
		// if (ballPosition.Y > 0.985) {
		// 	// Play sound
		// 	// soundBank.PlayCue("PongBallLost");
		// 	// Show lost message, reset is done above in StartNewBall!
		// 	lostGame = true;
		// 	pressSpaceToStart = true;
		// } // if

		// Check if all blocks are killed and if we won this level
		var allBlocksKilled = true
		// for (y := 0; y < NumOfRows; y++) {
		// 	for (int x = 0; x < NumOfColumns; x++) {
		// 		if (blocks[x, y]) {
		// 			allBlocksKilled = false;
		// 			break;
		// 		} // for for if
		// 	}
		// }

		// We won, start next level
		if allBlocksKilled == true {
			// Play sound
			// soundBank.PlayCue("BreakoutVictory");
			game.lostGame = false
			game.level++
			// StartLevel();
		} // if
	}
	return nil
}

// #region Check ball collisions
// / <summary>
// / Check ball collisions
// / </summary>
func (game *Game) CheckBallCollisions(moveFactorPerSecond float64) {
	// Check top, left and right screen borders
	MinYPos := 0.0235
	if game.ballPosition.Y < MinYPos {
		game.ballSpeedVector.Y = -game.ballSpeedVector.Y
		// Move ball back into screen space
		if game.ballPosition.X < MinYPos {
			game.ballPosition.X = MinYPos
		}
		// Play hit sound
		// soundBank.PlayCue("PongBallHit");
	} // if
	MinXPos := 0.018
	if game.ballPosition.X < MinXPos || game.ballPosition.X > 1-MinXPos {
		game.ballSpeedVector.X = -game.ballSpeedVector.X
		// Move ball back into screen space
		if game.ballPosition.X < MinXPos {
			game.ballPosition.X = MinXPos
		}
		if game.ballPosition.X > 1-MinXPos {
			game.ballPosition.X = 1 - MinXPos
		}
		// Play hit sound
		// soundBank.PlayCue("PongBallHit");
	} // if

	// Check for collisions with the paddles
	// Construct bounding boxes to use the intersection helper method.
	// ballSize := new(Vector2) //(24 / 1024.0, 24 / 768.0);
	ballBox := new(BoundingBox)
	// new Vector3(ballPosition.X - ballSize.X / 2, ballPosition.Y - ballSize.Y / 2, 0),
	// new Vector3(ballPosition.X + ballSize.X / 2, ballPosition.Y + ballSize.Y / 2, 0));

	// paddleSize := new(Vector2)
	//	GamePaddleRect.Width / 1024.0, GamePaddleRect.Height / 768.0);

	paddleBox := new(BoundingBox)
	// new Vector3(paddlePosition - paddleSize.X / 2, 0.95 - paddleSize.Y * 0.7, 0),
	// new Vector3(paddlePosition + paddleSize.X / 2, 0.95, 0));

	// Ball hit paddle?
	if ballBox.Intersects(paddleBox) {
		// Bounce off in the direction vector from the paddle
		game.ballSpeedVector.X += (game.ballPosition.X - game.paddlePosition) / (MinXPos * 3)
		// Max to -1 and +1
		if game.ballSpeedVector.X < -1 {
			game.ballSpeedVector.X = -1
		}
		if game.ballSpeedVector.X > 1 {
			game.ballSpeedVector.X = 1
		}
		// Bounce of the paddle
		game.ballSpeedVector.Y = -1 // -ballSpeedVector.Y;
		// Move away from the paddle
		game.ballPosition.Y -= moveFactorPerSecond * BallSpeedMultiplicator
		// Normalize vector
		game.ballSpeedVector.Normalize()
		// Play sound
		// soundBank.PlayCue("PongBallHit");
	} // if

	// Ball hits any block?
	for y := 0; y < NumOfRows; y++ {
		for x := 0; x < NumOfColumns; x++ {
			if game.blocks[x][y] {
				// Collision check
				block := game.blockBoxes[x][y]
				if ballBox.Intersects(&block) {//game.blockBoxes[x][y]) {
					// Kill block
					game.blocks[x][y] = false
					// Add score
					game.score += 1
					// Update title
					// Window.Title =
					// 	"XnaBreakout - Level " + (level + 1) + " - Score " + score;
					// Play sound
					// soundBank.PlayCue("BreakoutBlockKill");

					// Bounce ball back, but first find out which side we hit.
					// Start with left/right borders.
					if math.Abs(game.blockBoxes[x][y].Max.X-ballBox.Min.X) < moveFactorPerSecond {
						// ballSpeedVector.X = Math.Abs(ballSpeedVector.X);
						// // Also move back a little
						// ballPosition.X += (ballSpeedVector.X < 0 ? -1 : 1) * moveFactorPerSecond;
					} else if math.Abs(game.blockBoxes[x][y].Min.X-ballBox.Max.X) < moveFactorPerSecond {
						game.ballSpeedVector.X = -math.Abs(game.ballSpeedVector.X)
						// // Also move back a little
						// ballPosition.X += (ballSpeedVector.X < 0 ? -1 : 1) * moveFactorPerSecond;
						// Now check top/bottom borders
					} else if math.Abs(game.blockBoxes[x][y].Max.Y-ballBox.Min.Y) < moveFactorPerSecond {
						game.ballSpeedVector.Y = math.Abs(game.ballSpeedVector.Y)
						// // Also move back a little
						// ballPosition.Y += (ballSpeedVector.Y < 0 ? -1 : 1) * moveFactorPerSecond;
					} else if math.Abs(game.blockBoxes[x][y].Min.Y-ballBox.Max.Y) < moveFactorPerSecond {
						game.ballSpeedVector.Y = -math.Abs(game.ballSpeedVector.Y)
						// // Also move back a little
						// ballPosition.Y += (ballSpeedVector.Y < 0 ? -1 : 1) * moveFactorPerSecond;
					} else {
						game.ballSpeedVector.X *= -1
						game.ballSpeedVector.Y *= -1
					}
					// Go outa here, only handle 1 block at a time
					break
				} // if
			} // for for if
		}
	}
} // CheckBallCollisions()
// #endregion

func CheckKeypress(game *Game) (bool, error) {
	if ebiten.IsKeyPressed(ebiten.KeyArrowRight) {
		batX += 2
	}
	if ebiten.IsKeyPressed(ebiten.KeyArrowLeft) {
		batX -= 2
	}
	if game.pressSpaceToStart {
		if ebiten.IsKeyPressed(ebiten.KeySpace) {
			game.StartNewBall()
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

	score_str := fmt.Sprintf("Score: %d", game.score)
	text.Draw(screen, score_str, mplusNormalFont, 100, 100, color.White)
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int) {
	return width, height
}
