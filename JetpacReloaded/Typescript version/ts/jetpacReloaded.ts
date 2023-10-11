import { Game } from "../ts_lib/game.js"
// import { Game } from "../XNA_Typescript/XNA-TS/Library/lib/game.js";

import { SpriteBatch, SpriteEffects, Texture2D } from "../ts_lib/spritebatch.js";
import { TimeSpan } from "../ts_lib/timespan.js";
import { Vector2 } from "../ts_lib/vector2.js";
import { GameTime } from "../ts_lib/gametime.js";
import { Color } from "../ts_lib/color.js";
import { Controls } from "../ts_lib/controls.js";
import { Camera } from "./camera.js";
import { Rectangle } from "../ts_lib/rectangle.js";
import { Fuel } from "./fuel.js";
import { Tile, TileCollisionType } from "./tile.js";
import { Explosion } from "./explosion.js";
import { LevelManager } from "./levelManager.js";
import { Jetman } from "./jetman.js";
import { GraphicsDeviceManager } from "../ts_lib/graphicsdevicemanager.js";
import { Keys, Keyboard } from "../ts_lib/keyboardstate.js";

export enum GameState {
    gameStart,
    gameOn,
    gameOver,
    takeOff,
    nextLevel
}

export class JetPacReloaded extends Game {

    private m_rocket1X: number = 2000;
    private m_rocket1Y: number = 850;
    private m_rocket2X: number = 110;
    private m_rocket2Y: number = 139;
    private m_rocket3X: number = 510;
    private m_rocket3Y: number = 75;
    private m_score: number = 0;
    private m_lives: number = 3000;
    private m_level: number = 0;
    private m_fuelLevel: number = 0;
    private m_currentFrame: number = 0;
    private x: number = 400;
    private y: number = 300;
    private m_srollX: number = 0;
    private m_srollY: number = 0;

    private rocketLowerPosition: number = 422;
    private fuelLowerPosition: number = 430;

    private gameState: GameState = GameState.gameOn;//.gameOver;
    private m_graphics: GraphicsDeviceManager;
    private m_spriteBatch: SpriteBatch;

    private m_font = "Arial";

    private m_menuTexture: Texture2D;
    private m_jetmanTexture: Texture2D;
    private m_rocketTexture: Texture2D;
    private m_floorTexture: Texture2D;
    private m_ledge1Texture: Texture2D;
    private m_ledge2Texture: Texture2D;
    private m_explosionTexture: Texture2D;
    private m_particleTexture: Texture2D;
    private m_starTexture: Texture2D;
    private m_enemyTexture: Texture2D;
    private m_bulletTexture: Texture2D;
    private m_fuelTexture: Texture2D;
    private m_bonusTexture: Texture2D;
    private undergroundTiles: Texture2D;
    private m_rustyTexture: Texture2D;
    private jetmanMask: Texture2D;
    private lightMask: Texture2D;
    private _texture: Texture2D;

    // private Effect lightingEffect;
    // private RenderTarget2D lightsTarget;
    // private RenderTarget2D mainTarget;

    // private SoundEffect died;
    // private SoundEffect fire;
    // private SoundEffect hit;

    private scoreLocation: Vector2 = new Vector2(10, 10);
    private rocketLocation1: Vector2;
    private rocketLocation2: Vector2;
    private rocketLocation3: Vector2;
    private m_jetManPosition: Vector2;

    private flip: SpriteEffects = SpriteEffects.None;

    private m_drawnWithLighting: boolean = false;
    private m_onGround: boolean = false;
    private m_fuelAdded: boolean = false;
    private m_fuelLowering: boolean = false;
    private m_walking: boolean = false;
    private m_scrolling: boolean = false;
    private m_firstSectionLowering: boolean = false;
    private m_firstSectionComplete: boolean = false;
    private m_secondSectionLowering: boolean = false;
    private m_secondSectionComplete: boolean = false;
    private m_wallCollsion: boolean = false;

    private m_animationTimer: number = 0;
    private m_gameStartingDelay: number = 0;
    private m_delayCounter: number = 0;
    private m_elapsedCounter: number = 0.1;

    // private List<Enemy> m_enemies = new List<Enemy>();
    // private List<Star> m_stars = new List<Star>();
    // private List<Particle> m_particles = new List<Particle>();
    // private List<Bullet> m_bullets = new List<Bullet>();
    // private List<Rocket> m_rockets = new List<Rocket>();
    // private List<Fuel> m_fuel = new List<Fuel>();
    // private List<Ledge> m_ledge = new List<Ledge>();
    // private List<Bonus> m_bonus = new List<Bonus>();
    // private List<Explosion> m_explosion = new List<Explosion>();

    private m_jetman: Jetman;
    private m_graphicsManager: LevelManager;
    private m_camera: Camera;

    constructor() {
        super();
        this.m_graphics = new GraphicsDeviceManager(this);
        this.Content.RootDirectory = "Content";
        // IsMouseVisible = true;
    }

    protected Initialize(): void {
        // this.m_graphics.PreferredBackBufferWidth = 1024;
        // this.m_graphics.PreferredBackBufferHeight = 768;
        // this.m_graphics.ApplyChanges();
        // this.rocketLocation1 = new Vector2(this.m_rocket1X, this.m_rocket1Y);
        // this.rocketLocation2 = new Vector2(this.m_rocket2X, this.m_rocket2Y);
        // this.rocketLocation3 = new Vector2(this.m_rocket3X, this.m_rocket3Y);
        this.m_jetManPosition = new Vector2(this.x, this.y);
        // this._texture = new Texture2D(GraphicsDevice, 1, 1);
        // this._texture.SetData(Color.DarkSlateGray);
        super.Initialize(this);
    }

    protected LoadContent(): void {
        this.m_spriteBatch = new SpriteBatch();
        // this.m_font = Content.Load<SpriteFont>("font");

        this.m_bonusTexture = this.Content.Load<Texture2D>("bonus");
        this.m_bulletTexture = this.Content.Load<Texture2D>("bullet");
        this.m_enemyTexture = this.Content.Load<Texture2D>("enemies");
        this.m_explosionTexture = this.Content.Load<Texture2D>("explosion");
        this.m_fuelTexture = this.Content.Load<Texture2D>("fuel");
        this.m_jetmanTexture = this.Content.Load<Texture2D>("man");

        // this.m_menuTexture = Content.Load<Texture2D>("loading");
        // this.m_particleTexture = Content.Load<Texture2D>("particle");
        // this.m_rocketTexture = Content.Load<Texture2D>("rocket");
        // this.m_starTexture = Content.Load<Texture2D>("star");

        this.undergroundTiles = this.Content.Load<Texture2D>("undergroundTiles");
        this.m_rustyTexture = this.Content.Load<Texture2D>("rusty");

        // this.jetmanMask = Content.Load<Texture2D>("playermask");
        // this.lightMask = Content.Load<Texture2D>("lightmask");

        // this.lightingEffect = Content.Load<Effect>("Effect1");
        // var pp = GraphicsDevice.PresentationParameters;
        // this.lightsTarget = new RenderTarget2D(GraphicsDevice, pp.BackBufferWidth, pp.BackBufferHeight);
        // this.mainTarget = new RenderTarget2D(GraphicsDevice, pp.BackBufferWidth, pp.BackBufferHeight);

        // this.died = Content.Load<SoundEffect>("died");
        // this.fire = Content.Load<SoundEffect>("fire");
        // this.hit = Content.Load<SoundEffect>("hit");

        this.m_jetman = new Jetman(400, 300, this.m_jetmanTexture, this._texture);
        // this.m_rockets.Add(new Rocket(<number>this.rocketLocation1.X, <number>this.rocketLocation1.Y, this.m_rocketTexture, 0, 75, 61));
        // this.m_rockets.Add(new Rocket(<number>this.rocketLocation2.X, <number>this.rocketLocation2.Y, this.m_rocketTexture, 4, 75, 61));
        // this.m_rockets.Add(new Rocket(<number>this.rocketLocation3.X, <number>this.rocketLocation3.Y, this.m_rocketTexture, 8, 75, 61));
        // this.m_bonus.Add(new Bonus(this.m_bonusTexture));
        // for (var i: number = 0; i < 10; i++) {
        //     this.m_enemies.Add(new Enemy(this.m_enemyTexture));
        // }
        // for (var i: number = 0; i < 40; i++) {
        //     this.m_stars.Add(new Star(this.m_starTexture));
        //     this.m_particles.Add(new Particle(this.m_particleTexture));
        // }
        this.m_graphicsManager = new LevelManager();
        this.m_graphicsManager.LoadLevels();
        this.m_camera = new Camera();
        this.m_camera.Follow(this.m_jetman);
    }
    protected Update(gameTime: GameTime): void {
        // if (this.gameState == GameState.gameStart) {
        //     this.m_gameStartingDelay += Game1.m_elapsedCounter;
        //     if (this.m_gameStartingDelay > 10) {
        //         this.gameState = GameState.gameOn;
        //     }
        // }
        // this.CheckScreenBounds();
        // if (!this.m_walking) {

        // }
        // this.m_stars.forEach(function (star) {
        //     star.Update();
        // });
        // this.m_enemies.forEach(function (alien) {
        //     alien.Update(this.m_level);
        // });
        // let tempBullet = new List<Bullet>();
        // this.m_bullets.forEach(function (bullet) {
        //     if (!bullet.Offscreen) {
        //         bullet.Update();
        //         tempBullet.Add(bullet);
        //     }
        // });
        // this.m_bullets = tempBullet;
        // let tempExplosion = new List<Explosion>();
        // this.m_explosion.forEach(function (explosion) {
        //     if (!explosion.AnimationComplete) {
        //         explosion.Update();
        //         tempExplosion.Add(explosion);
        //     }
        // });
        // this.m_explosion = tempExplosion;
        // this.m_bonus.forEach(function (bonus) {
        //     bonus.Update();
        // });
        this.CheckRocketCollsions();
        this.LowerRocketSections();
        this.CheckBulletCollisions();
        this.CheckEnemyCollisions();
        this.CheckBonusCollisions();
        this.CheckKeyboard();
        // this.m_particles.forEach(function (particle) {
        //     if (this.m_fuelLevel < 100) {
        //         particle.Update(this.x, this.y, this.flip != SpriteEffects.None, !this.m_onGround);
        //     }
        //     else {
        //         particle.Update(Game1.rocketLowerPosition + 36, this.m_rockets[0].RocketRect.Y + 36, false, true);
        //     }
        // });
        // if (this.m_secondSectionComplete && !this.m_fuelAdded) {
        //     this.AddFuel();
        //     this.m_fuelAdded = true;
        // }
        // var nextFuel: boolean = false;
        // this.m_fuel.forEach(function (fuel) {
        //     fuel.Update(this.m_ledge);
        //     this.CheckFuelCollisions(fuel);
        //     if (this.m_fuelLowering && fuel.LowerFuel() && this.m_fuelLevel < 100) {
        //         this.m_fuelLevel += 25;
        //         this.m_fuelLowering = false;
        //         nextFuel = true;
        //     }
        // });
        // if (nextFuel) {
        //     this.AddFuel();
        // }
        // if (this.m_lives < 1) {
        //     this.gameState = GameState.gameOver;
        // }
        // if (this.gameState == GameState.takeOff) {
        //     this.m_rockets.forEach(function (rocket) {
        //         if (!rocket.TakeOff()) {
        //             this.m_level++;
        //             this.gameState = GameState.nextLevel;
        //         }
        //     });
        // }
        // if (this.gameState == GameState.nextLevel) {
        //     this.ResetLevel();
        //     this.gameState = GameState.gameOn;
        // }
        this.m_camera.Follow(this.m_jetman);
        super.Update(gameTime);
    }

    private CheckBulletCollisions(): void {
        // var bulletToRemove: Bullet = null;
        // this.m_enemies.forEach(function (alien) {
        //     this.m_bullets.forEach(function (bullet) {
        //         if (bullet.BulletRect.Intersects(alien.AlienRect)) {
        //             this.m_explosion.Add(new Explosion(alien.AlienRect.X, alien.AlienRect.Y, this.m_explosionTexture));
        //             alien.ResetMeteor();
        //             this.died.Play();
        //             bulletToRemove = bullet;
        //             this.m_score += 100;
        //             break;
        //         }
        //     });
        // });
        // if (bulletToRemove != null) {
        //     this.m_bullets.Remove(bulletToRemove);
        // }
    }

    private CheckEnemyCollisions(): void {
        // this.m_enemies.forEach(function (alien) {
        //     if (alien.AlienRect.Intersects(this.m_jetman.JetmanRect) && this.gameState == GameState.gameOn) {
        //         this.m_explosion.Add(new Explosion(alien.AlienRect.X, alien.AlienRect.Y, this.m_explosionTexture));
        //         alien.ResetMeteor();
        //         this.died.Play();
        //         this.m_lives--;
        //         break;
        //     }
        //     this.m_ledge.forEach(function (ledge) {
        //         if (alien.AlienRect.Intersects(ledge.LedgeRect)) {
        //             this.m_explosion.Add(new Explosion(alien.AlienRect.X, alien.AlienRect.Y, this.m_explosionTexture));
        //             alien.ResetMeteor();
        //             this.hit.Play();
        //         }
        //     });
        // });
    }

    private CheckBonusCollisions(): void {
        // this.m_bonus.forEach(function (bonus) {
        //     this.m_ledge.forEach(function (ledge) {
        //         if (bonus.BonRect.Intersects(ledge.LedgeRect)) {
        //             bonus.BonusLanded = true;
        //         }
        //     });
        //     if (this.m_jetman.JetmanRect.Intersects(bonus.BonRect)) {
        //         bonus.Reset();
        //         this.m_score += 100;
        //     }
        // });
    }
    private CheckRocketCollsions(): void {
        // if (this.m_jetman.JetmanRect.Intersects(this.m_rockets[1].RocketRect) && !this.m_firstSectionLowering) {
        //     if (<number>this.m_jetman.JetmanPosition.X != Game1.rocketLowerPosition) {
        //         this.m_rockets[1].Update(<number>this.m_jetman.JetmanPosition.X, <number>this.m_jetman.JetmanPosition.Y);
        //     }
        //     else {
        //         this.m_firstSectionLowering = true;
        //     }
        // }
        // if (this.m_jetman.JetmanRect.Intersects(this.m_rockets[2].RocketRect) && this.m_firstSectionComplete && !this.m_secondSectionLowering) {
        //     if (<number>this.m_jetman.JetmanPosition.X != Game1.rocketLowerPosition) {
        //         this.m_rockets[2].Update(<number>this.m_jetman.JetmanPosition.X, <number>this.m_jetman.JetmanPosition.Y);
        //     }
        //     else {
        //         this.m_secondSectionLowering = true;
        //     }
        // }
    }

    private CheckJetManLedgeCollsions(tile: Tile): void {
        // this.m_wallCollsion = false;
        // var ledge: Rectangle = tile.TileRect;
        // if (this.m_jetman.JetmanRect.Intersects(tile.TileRect)) {
        //     if (tile.GetTileCollisionType.Equals(TileCollisionType.Wall)) {
        //         this.m_wallCollsion = true;
        //         var halfWidthA: number = ledge.Width / 2.0;
        //         var halfHeightA: number = ledge.Height;
        //         var halfWidthB: number = this.m_jetman.JetmanRect.Width / 2.0;
        //         var halfHeightB: number = this.m_jetman.JetmanRect.Height;
        //         var centerA: Vector2 = new Vector2(ledge.Left + halfWidthA, ledge.Top + halfHeightA);
        //         var centerB: Vector2 = new Vector2(this.m_jetman.JetmanRect.Left + halfWidthB, this.m_jetman.JetmanRect.Top + halfHeightB);
        //         var distanceX: number = centerA.X - centerB.X;
        //         var distanceY: number = centerA.Y - centerB.Y;
        //         var minDistanceX: number = halfWidthA + halfWidthB;
        //         var minDistanceY: number = halfHeightA + halfHeightB;
        //         var depthX: number = distanceX > 0 ? minDistanceX - distanceX : -minDistanceX - distanceX;
        //         var depthY: number = distanceY > 0 ? minDistanceY - distanceY : -minDistanceY - distanceY;
        //         if (depthX >= -2 && depthX <= 2) {
        //             this.m_wallCollsion = true;
        //             this.x -= <number>Math.ceil(depthX) - 6;
        //             this.x = 64;
        //             if (centerA.X < centerB.X) {
        //                 this.x = ledge.Right + 2;
        //             }
        //             if (centerA.X > centerB.X) {
        //                 this.x = this.m_jetman.JetmanRect.Left - 4;
        //             }
        //         }
        //         if (depthY < -50) {
        //             var i: number = 0;
        //             this.y = this.m_jetman.JetmanRect.Top + 4;
        //         }
        //     }
        //     if (tile.GetTileCollisionType.Equals(TileCollisionType.Platform)) {
        //         this.y = this.m_jetman.JetmanRect.Top - 4;
        //     }
        //     this.m_jetManPosition = new Vector2(this.x, this.y);
        // }
    }

    private CheckFuelCollisions(fuel: Fuel): void {
        // if (this.m_jetman.JetmanRect.Intersects(fuel.FuelRect)) {
        //     if (<number>this.m_jetman.JetmanPosition.X != this.fuelLowerPosition && !this.m_fuelLowering) {
        //         fuel.UpdatePosition(<number>this.m_jetman.JetmanPosition.X, <number>this.m_jetman.JetmanPosition.Y);
        //     }
        //     else {
        //         this.m_fuelLowering = true;
        //     }
        // }
    }

    private LowerRocketSections(): void {
        // if (this.m_firstSectionLowering && !this.m_firstSectionComplete) {
        //     this.m_firstSectionComplete = this.m_rockets[1].LowerSectionOne();
        // }
        // if (this.m_secondSectionLowering && !this.m_secondSectionComplete) {
        //     this.m_secondSectionComplete = this.m_rockets[2].LowerSectionTwo();
        // }
    }

    private AddFuel(): void {
        // this.m_fuel.Clear();
        // if (this.m_fuelLevel != 100) {
        //     this.m_fuel.Add(new Fuel(this.m_fuelTexture));
        // }
        // else {
        //     this.gameState = GameState.takeOff;
        //     this.m_score += 100;
        // }
    }

    private CheckScreenBounds(): void {
        if (this.y > 850) {
            this.y = 850;
        }
    }

    private CheckKeyboard(): void {
        let testX: number = 0;
        let testY: number = 0;

        // if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed || Keyboard.GetState().IsKeyDown(Keys.Escape))
        //     Exit();
        // if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed || Keyboard.GetState().IsKeyDown(Keys.X)) {
        //     if (this.gameState == GameState.gameOver) {
        //         this.gameState = GameState.gameStart;
        //         this.ResetGame();
        //     }
        // }

        if (/*GamePad.GetState(PlayerIndex.One).DPad.Down == ButtonState.Pressed ||*/ Keyboard.GetState().IsKeyDown(Keys.Down)) {
            if (!this.m_onGround) {
                testY = 2;
                this.CheckScreenBounds();
                this.m_currentFrame = 0;
            }
        }

        if (/*GamePad.GetState(PlayerIndex.One).DPad.Up == ButtonState.Pressed ||*/ Keyboard.GetState().IsKeyDown(Keys.Up)) {
            testY = -2;
            this.CheckScreenBounds();
            this.m_onGround = false;
            this.m_walking = false;
            this.m_currentFrame = 0;
        }

        if (/*GamePad.GetState(PlayerIndex.One).DPad.Left == ButtonState.Pressed ||*/ Keyboard.GetState().IsKeyDown(Keys.Left)) {
            this.flip = SpriteEffects.FlipHorizontally;
            // if (!this.m_wallCollsion) {
            // }
            testX = -4;
            this.m_animationTimer += this.m_elapsedCounter;
            this.CheckScreenBounds();
            if (this.m_onGround && this.m_animationTimer > 0.4) {
                this.m_currentFrame = (this.m_currentFrame + 1) % 4;
                if (this.m_currentFrame == 0) {
                    this.m_currentFrame = 1;
                }
                this.m_animationTimer = 0;
            }
        }

        if (/*GamePad.GetState(PlayerIndex.One).DPad.Right == ButtonState.Pressed ||*/ Keyboard.GetState().IsKeyDown(Keys.Right)) {
            this.flip = SpriteEffects.None;
            // if (!this.m_wallCollsion) {
            // }
            testX = 4;
            this.m_animationTimer += this.m_elapsedCounter;
            this.CheckScreenBounds();
            if (this.m_onGround && this.m_animationTimer > 0.4) {
                this.m_currentFrame = (this.m_currentFrame + 1) % 4;
                if (this.m_currentFrame == 0) {
                    this.m_currentFrame = 1;
                }
                this.m_animationTimer = 0;
            }
        }

        if (/*GamePad.GetState(PlayerIndex.One).Buttons.LeftShoulder == ButtonState.Pressed ||*/ Keyboard.GetState().IsKeyDown(Keys.LeftControl)) {
            // this.fire.Play();
            this.m_delayCounter += this.m_elapsedCounter;
            if (this.m_delayCounter > 0.4) {
                if (this.flip == SpriteEffects.None) {
                    //this.m_bullets.Add(new Bullet(this.x, this.m_jetman.JetmanRect.Center.Y, this.m_bulletTexture, false));
                }
                else {
                    //this.m_bullets.Add(new Bullet(this.x, this.m_jetman.JetmanRect.Center.Y, this.m_bulletTexture, true));
                }
                this.m_delayCounter = 0;
            }
        }

        if (Keyboard.GetState().IsKeyDown(Keys.A)) {
            this.m_drawnWithLighting = true;
        }

        if (Keyboard.GetState().IsKeyDown(Keys.S)) {
            this.m_drawnWithLighting = false;
        }

        this.m_jetman.JetmanAnimFrame = this.m_currentFrame;
        let floaterX: number = this.x += this.getVelocityX(testX);
        let floaterY: number = this.y += this.getVelocityY(testY);
        this.m_jetManPosition = new Vector2(floaterX, floaterY);
        this.m_jetman.Update(this.m_jetManPosition, this.flip);
    }

    private checkForHorizontalIntersections(increment: number): number {
        let testRect: Rectangle = new Rectangle((this.m_jetman.JetmanPosition.X + increment), this.m_jetman.JetmanPosition.Y, this.m_jetman.JetmanRect.Width, this.m_jetman.JetmanRect.Height - 5);
        this.m_graphicsManager.TileList.forEach(function (tile) {
            if (testRect.Intersects(tile.TileRect)) {
                increment = 0;
                return increment;
            }
        });
        return increment;
    }

    private checkForVerticalIntersections(increment: number): number {
        let testRect: Rectangle = new Rectangle(this.m_jetman.JetmanPosition.X, (this.m_jetman.JetmanPosition.Y + increment), this.m_jetman.JetmanRect.Width, this.m_jetman.JetmanRect.Height - 5);
        this.m_graphicsManager.TileList.forEach(function (tile) {
            if (testRect.Intersects(tile.TileRect)) {
                increment = 0;
                return increment;
            }
        });
        return increment;
    }

    public getVelocityX(speed: number): number {
        let pixelMovement: number = 0;
        let pixels: number = 0;
        if (speed != 0) {
            if (speed > 0) {
                for (let increment: number = 0; increment < speed; increment++) {
                    pixelMovement = this.checkForHorizontalIntersections(++pixels);
                }
            }
            else if (speed < 0) {
                pixels = 0;
                for (let increment: number = 0; increment > speed; increment--) {
                    pixelMovement = this.checkForHorizontalIntersections(--pixels);
                }
            }
        }
        return pixelMovement;
    }
    public getVelocityY(speed: number): number {
        let pixelMovement: number = 0;
        let pixels: number = 0;
        if (speed != 0) {
            if (speed > 0) {
                for (let increment: number = 0; increment < speed; increment++) {
                    pixelMovement = this.checkForVerticalIntersections(++pixels);
                }
            }
            else if (speed < 0) {
                pixels = 0;
                for (let increment: number = 0; increment > speed; increment--) {
                    pixelMovement = this.checkForVerticalIntersections(--pixels);
                }
            }
        }
        return pixelMovement;
    }

    private ResetGame(): void {
        this.m_score = 0;
        this.m_lives = 3;
        this.m_level = 0;
        this.m_fuelLevel = 0;
        this.m_currentFrame = 0;
        this.x = 150;
        this.y = 300;
        this.ResetLevel();
    }

    private ResetLevel(): void {
        this.x = 150;
        this.y = 300;
        this.m_rocket1X = 422;
        this.m_rocket1Y = 443;
        this.m_rocket2X = 110;
        this.m_rocket2Y = 139;
        this.m_rocket3X = 510;
        this.m_rocket3Y = 75;
        this.m_fuelLevel = 0;
        this.m_fuelAdded = false;
        this.m_fuelLowering = false;
        this.m_firstSectionLowering = false;
        this.m_firstSectionComplete = false;
        this.m_secondSectionLowering = false;
        this.m_secondSectionComplete = false;
        this.rocketLocation1 = new Vector2(this.m_rocket1X, this.m_rocket1Y);
        this.rocketLocation2 = new Vector2(this.m_rocket2X, this.m_rocket2Y);
        this.rocketLocation3 = new Vector2(this.m_rocket3X, this.m_rocket3Y);
        // this.m_rockets.Clear();
        // let frame: number = this.m_level % 4;
        // this.m_rockets.Add(new Rocket(<number>this.rocketLocation1.X, <number>this.rocketLocation1.Y, this.m_rocketTexture, frame, 75, 61));
        // this.m_rockets.Add(new Rocket(<number>this.rocketLocation2.X, <number>this.rocketLocation2.Y, this.m_rocketTexture, frame + 4, 75, 61));
        // this.m_rockets.Add(new Rocket(<number>this.rocketLocation3.X, <number>this.rocketLocation3.Y, this.m_rocketTexture, frame + 8, 75, 61));
        // this.m_enemies.forEach(function (alien) {
        //     alien.ResetMeteor();
        // });
    }

    protected Draw(gameTime: GameTime): void {
        this.m_spriteBatch.Clear(Color.Black);

        if (this.gameState == GameState.gameOver) {
            //     this.m_spriteBatch.Begin();
            //     this.m_spriteBatch.Draw(this.m_menuTexture, new Vector2(0, 0), Color.White);
            //     this.m_spriteBatch.DrawString(this.m_font, "JetPac the Remake (Monogame Update)", new Vector2(150.0f, 440.0f), Color.Yellow);
            //     this.m_spriteBatch.DrawString(this.m_font, "Written by Ian Wigley", new Vector2(150.0f, 460.0f), Color.Yellow);
            //     this.m_spriteBatch.DrawString(this.m_font, "In 2020", new Vector2(150.0f, 480.0f), Color.Yellow);
            //     this.m_spriteBatch.DrawString(this.m_font, "Press X to start", new Vector2(150.0f, 520.0f), Color.Yellow);
            //     this.m_spriteBatch.End();
        }
        else {
            //     if (this.m_drawnWithLighting) {
            //         GraphicsDevice.SetRenderTarget(this.lightsTarget);
            //         GraphicsDevice.Clear(Color.Black);
            //         this.m_spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.Additive,/*transformMatrix:*/this.m_camera.Transform);
            //         this.m_spriteBatch.Draw(this.jetmanMask, new Vector2(this.x - 280, this.y - 280), Color.White);
            //         this.m_spriteBatch.Draw(this.lightMask, new Vector2(160, 100), Color.White);
            //         this.m_spriteBatch.Draw(this.lightMask, new Vector2(590, 100), Color.White);
            //         this.m_spriteBatch.End();
            //         GraphicsDevice.SetRenderTarget(this.mainTarget);
            //     }
            this.m_spriteBatch.Begin(this.m_camera.Transform);
            this.m_spriteBatch.Draw(this.m_rustyTexture, new Vector2(0, 0), Color.White);
            this.m_graphicsManager.TileList.forEach(i => {
                if (i.Drawable(this.x, this.y)) {
                    // // this.m_spriteBatch.Draw(this._texture, i.TileRect, i.TileTexture, Color.White);
                    this.m_spriteBatch.Draw(this.undergroundTiles, i.TileRect, i.TileTexture, Color.White);
                }
            });
            //     this.m_stars.forEach(function (star) {
            //         star.Draw(this.m_spriteBatch);
            //     });
            //     this.m_enemies.forEach(function (alien) {
            //         alien.Draw(this.m_spriteBatch);
            //     });
            //     this.m_explosion.forEach(function (explosion) {
            //         explosion.Draw(this.m_spriteBatch);
            //     });
            //     this.m_bullets.forEach(function (bullet) {
            //         bullet.Draw(this.m_spriteBatch);
            //     });
            //     this.m_fuel.forEach(function (fuel) {
            //         fuel.Draw(this.m_spriteBatch);
            //     });
            //     this.m_bonus.forEach(function (bonus) {
            //         bonus.Draw(this.m_spriteBatch);
            //     });
            //     this.m_rockets.forEach(function (rocket) {
            //         rocket.Draw(this.m_spriteBatch);
            //     });
            //     this.m_ledge.forEach(function (ledge) {
            //         ledge.Draw(this.m_spriteBatch);
            //     });
            this.m_jetman.Draw(this.m_spriteBatch);
            this.m_spriteBatch.End();
            // this.m_particles.forEach(function (particle) {
            //     particle.Draw(this.m_spriteBatch, this.m_camera);
            // });
            // if (this.m_drawnWithLighting) {
            //     GraphicsDevice.SetRenderTarget(null);
            //     GraphicsDevice.Clear(Color.CornflowerBlue);
            //     this.m_spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend);
            //     this.lightingEffect.Parameters["lightMask"].SetValue(this.lightsTarget);
            //     this.lightingEffect.CurrentTechnique.Passes[0].Apply();
            //     this.m_spriteBatch.Draw(this.mainTarget, Vector2.Zero, Color.White);
            //     this.m_spriteBatch.End();
            // }

            // this.m_spriteBatch.Begin();
            // this.m_spriteBatch.DrawString(this.m_font, "SCORE : " + this.m_score.ToString("D4"), this.scoreLocation + new Vector2(1.0f, 1.0f), Color.Yellow);
            this.m_spriteBatch.DrawString(this.m_font, "SCORE : " + this.m_score, this.scoreLocation, Color.Yellow);
            // this.m_spriteBatch.DrawString(this.m_font, "FUEL : " + this.m_fuelLevel + "%", this.scoreLocation + new Vector2(350.0f, 1.0f), Color.Yellow);
            // this.m_spriteBatch.DrawString(this.m_font, "LIVES : " + this.m_lives, this.scoreLocation + new Vector2(700.0f, 1.0f), Color.Yellow);
            this.m_spriteBatch.DrawString(this.m_font, "x : " + this.x + " y : " + this.y, new Vector2(10, this.scoreLocation.Y + 15), Color.Yellow);
            // this.m_spriteBatch.DrawString(this.m_font, "x scroll : " + this.m_srollX + " y scroll : " + this.m_srollY, this.scoreLocation + new Vector2(1.0f, 30.0f), Color.Yellow);
            this.m_spriteBatch.DrawString(this.m_font, "x camera : " + this.m_camera.CameraPos.X + " y camera : " + this.m_camera.CameraPos.Y, new Vector2(10, this.scoreLocation.Y + 45), Color.Yellow);
            this.m_spriteBatch.DrawString(this.m_font, "x : " + this.m_jetman.JetmanPosition.X + " y : " + this.m_jetman.JetmanPosition.Y, new Vector2(10, this.scoreLocation.Y + 60), Color.Yellow);
            // this.m_spriteBatch.End();
        }
        super.Draw(gameTime);
    }
}
