//////////////////////////////////////////////////////////
//                                                      //
//         JetPac - Written by Ian Wigley               //
//           Monogame re-write Nov 2020                 //
//    Static values removed & general code clean up     //
//                                                      //
//////////////////////////////////////////////////////////

using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using System;
using System.Collections.Generic;

namespace JetpacReloaded
{
    enum GameState
    {
        gameStart,
        gameOn,
        gameOver,
        takeOff,
        nextLevel
    }

    public class Game1 : Game
    {
        private int m_rocket1X = 2000;//422;
        private int m_rocket1Y = 850;//443;
        private int m_rocket2X = 110;
        private int m_rocket2Y = 139;
        private int m_rocket3X = 510;
        private int m_rocket3Y = 75;
        private int m_score = 0;
        private int m_lives = 3000;
        private int m_level = 0;
        private int m_fuelLevel = 0;
        private int m_currentFrame = 0;
        private int x = 400;
        private int y = 300;

        private int m_srollX = 0;
        private int m_srollY = 0;

        private const int rocketLowerPosition = 422;
        private const int fuelLowerPosition = 430;

        private GameState gameState = GameState.gameOn;//.gameOver;
        private readonly GraphicsDeviceManager m_graphics;
        private SpriteBatch m_spriteBatch;

        private SpriteFont m_font;
        private Texture2D m_menuTexture;
        private Texture2D m_jetmanTexture;
        private Texture2D m_rocketTexture;
        private Texture2D m_floorTexture;
        private Texture2D m_ledge1Texture;
        private Texture2D m_ledge2Texture;
        private Texture2D m_explosionTexture;
        private Texture2D m_particleTexture;
        private Texture2D m_starTexture;
        private Texture2D m_enemyTexture;
        private Texture2D m_bulletTexture;
        private Texture2D m_fuelTexture;
        private Texture2D m_bonusTexture;

        private Texture2D undergroundTiles;
        private Texture2D m_rustyTexture;

        private Texture2D jetmanMask;
        private Texture2D lightMask;
        private Effect lightingEffect;
        private RenderTarget2D lightsTarget;
        private RenderTarget2D mainTarget;

        private SoundEffect died;
        private SoundEffect fire;
        private SoundEffect hit;

        private Vector2 scoreLocation = new Vector2(10, 10);
        private Vector2 rocketLocation1;
        private Vector2 rocketLocation2;
        private Vector2 rocketLocation3;

        private SpriteEffects flip = SpriteEffects.None;

        private bool m_drawnWithLighting = false;
        private bool m_onGround = false;
        private bool m_fuelAdded = false;
        private bool m_fuelLowering = false;
        private bool m_walking = false;
        private bool m_scrolling = false;

        private bool m_firstSectionLowering = false;
        private bool m_firstSectionComplete = false;
        private bool m_secondSectionLowering = false;
        private bool m_secondSectionComplete = false;

        private double m_animationTimer = 0;
        private double m_gameStartingDelay = 0;
        private double m_delayCounter = 0;
        private const double m_elapsedCounter = 0.1;

        private readonly List<Enemy> m_enemies = new List<Enemy>();
        private List<Star> m_stars = new List<Star>();
        private List<Particle> m_particles = new List<Particle>();
        private List<Bullet> m_bullets = new List<Bullet>();
        private List<Rocket> m_rockets = new List<Rocket>();
        private List<Fuel> m_fuel = new List<Fuel>();
        private List<Ledge> m_ledge = new List<Ledge>();
        private List<Bonus> m_bonus = new List<Bonus>();
        private List<Explosion> m_explosion = new List<Explosion>();

        private Jetman m_jetman;
        private GraphicsManager m_graphicsManager;
        private Camera m_camera;

        private bool m_wallCollsion = false;
        private Vector2 m_jetManPosition;

        Texture2D _texture;


        public Game1()
        {
            m_graphics = new GraphicsDeviceManager(this);
            Content.RootDirectory = "Content";
            IsMouseVisible = true;
        }

        protected override void Initialize()
        {
            // TODO: Add your initialization logic here
            m_graphics.PreferredBackBufferWidth = 1024;// 800;
            m_graphics.PreferredBackBufferHeight = 768; // 600;
            m_graphics.ApplyChanges();

            rocketLocation1 = new Vector2(m_rocket1X, m_rocket1Y);
            rocketLocation2 = new Vector2(m_rocket2X, m_rocket2Y);
            rocketLocation3 = new Vector2(m_rocket3X, m_rocket3Y);
            m_jetManPosition = new Vector2(x, y);

            _texture = new Texture2D(GraphicsDevice, 1, 1);
            _texture.SetData(new Color[] { Color.DarkSlateGray });

            base.Initialize();
        }

        protected override void LoadContent()
        {
            m_spriteBatch = new SpriteBatch(GraphicsDevice);

            m_font = Content.Load<SpriteFont>("font");
            m_bonusTexture = Content.Load<Texture2D>("bonus");
            m_bulletTexture = Content.Load<Texture2D>("bullet");
            m_enemyTexture = Content.Load<Texture2D>("enemies");
            m_explosionTexture = Content.Load<Texture2D>("explosion");
            //m_floorTexture = Content.Load<Texture2D>("floor");
            m_fuelTexture = Content.Load<Texture2D>("fuel");
            m_jetmanTexture = Content.Load<Texture2D>("man");
            //m_jetmanTexture = Content.Load<Texture2D>("jetman");
            //m_ledge1Texture = Content.Load<Texture2D>("ledge1");
            //m_ledge2Texture = Content.Load<Texture2D>("ledge2");
            m_menuTexture = Content.Load<Texture2D>("loading");
            m_particleTexture = Content.Load<Texture2D>("particle");
            m_rocketTexture = Content.Load<Texture2D>("rocket");
            m_starTexture = Content.Load<Texture2D>("star");

            undergroundTiles = Content.Load<Texture2D>("undergroundTiles");
            m_rustyTexture = Content.Load<Texture2D>("rusty");

            jetmanMask = Content.Load<Texture2D>("playermask");
            lightMask = Content.Load<Texture2D>("lightmask");
            lightingEffect = Content.Load<Effect>("Effect1");

            var pp = GraphicsDevice.PresentationParameters;
            lightsTarget = new RenderTarget2D(
                GraphicsDevice, pp.BackBufferWidth, pp.BackBufferHeight);
            mainTarget = new RenderTarget2D(
                GraphicsDevice, pp.BackBufferWidth, pp.BackBufferHeight);


            died = Content.Load<SoundEffect>("died");
            fire = Content.Load<SoundEffect>("fire");
            hit = Content.Load<SoundEffect>("hit");

            m_jetman = new Jetman(400, 300, m_jetmanTexture, _texture);

            m_rockets.Add(new Rocket((int)rocketLocation1.X, (int)rocketLocation1.Y, m_rocketTexture, 0, 75, 61));
            m_rockets.Add(new Rocket((int)rocketLocation2.X, (int)rocketLocation2.Y, m_rocketTexture, 4, 75, 61));
            m_rockets.Add(new Rocket((int)rocketLocation3.X, (int)rocketLocation3.Y, m_rocketTexture, 8, 75, 61));

            //m_ledge.Add(new Ledge(60, 200, m_ledge1Texture));
            //m_ledge.Add(new Ledge(310, 265, m_ledge2Texture));
            //m_ledge.Add(new Ledge(490, 136, m_ledge1Texture));
            //m_ledge.Add(new Ledge(800, 500, m_floorTexture));

            m_bonus.Add(new Bonus(m_bonusTexture));

            for (int i = 0; i < 10; i++)
            {
                m_enemies.Add(new Enemy(m_enemyTexture));
            }

            for (int i = 0; i < 40; i++)
            {
                m_stars.Add(new Star(m_starTexture));
                m_particles.Add(new Particle(m_particleTexture));
            }

            m_graphicsManager = new GraphicsManager();
            m_graphicsManager.LoadLevels();

            m_camera = new Camera();
            m_camera.Follow(m_jetman);
        }

        protected override void Update(GameTime gameTime)
        {
            //CheckKeyboard();

            if (gameState == GameState.gameStart)
            {
                m_gameStartingDelay += m_elapsedCounter;
                if (m_gameStartingDelay > 10)
                {
                    gameState = GameState.gameOn;
                }
            }

            CheckScreenBounds();
            if (!m_walking)
            {
                //y += 1;
            }
            //VerticalScrollDown();

            foreach (Star star in m_stars)
            {
                star.Update();
            }

            foreach (Enemy alien in m_enemies)
            {
                alien.Update(m_level);
            }

            var tempBullet = new List<Bullet>();
            foreach (Bullet bullet in m_bullets)
            {
                if (!bullet.Offscreen)
                {
                    bullet.Update();
                    tempBullet.Add(bullet);
                }
            }
            m_bullets = tempBullet;

            var tempExplosion = new List<Explosion>();
            foreach (Explosion explosion in m_explosion)
            {
                if (!explosion.AnimationComplete)
                {
                    explosion.Update();
                    tempExplosion.Add(explosion);
                }
            }
            m_explosion = tempExplosion;

            foreach (Bonus bonus in m_bonus)
            {
                bonus.Update();
            }

            CheckRocketCollsions();
            LowerRocketSections();
            CheckBulletCollisions();
            CheckEnemyCollisions();
            CheckBonusCollisions();
            ////            CheckJetManLedgeCollsions();
            //m_graphicsManager.TileList.ForEach(tile =>
            //{
            //    //    if (tile.Drawable(x, y)) 
            //    { CheckJetManLedgeCollsions(tile); /* i.TileRect);*/ }
            //});

            CheckKeyboard();

            foreach (Particle particle in m_particles)
            {
                if (m_fuelLevel < 100)
                {
                    particle.Update(x, y, flip != SpriteEffects.None, !m_onGround);
                }
                else
                {
                    particle.Update(rocketLowerPosition + 36, m_rockets[0].RocketRect.Y + 36, false, true);
                }
            }

            if (m_secondSectionComplete && !m_fuelAdded)
            {
                AddFuel();
                m_fuelAdded = true;
            }

            bool nextFuel = false;
            foreach (Fuel fuel in m_fuel)
            {
                fuel.Update(m_ledge);
                CheckFuelCollisions(fuel);
                if (m_fuelLowering && fuel.LowerFuel() && m_fuelLevel < 100)
                {
                    //if (fuel.LowerFuel() && m_fuelLevel < 100)
                    //{
                    //if (m_fuelLevel < 100)
                    //{
                    m_fuelLevel += 25;
                    m_fuelLowering = false;
                    nextFuel = true;
                    //}
                    //}
                }
            }


            //if (m_scrolling)
            //{
            //    foreach (Ledge ledge in m_ledge)
            //    {

            //        ledge.Update(m_srollX, m_srollY);

            //    }
            //    m_scrolling = false;
            //}

            if (nextFuel)
            {
                AddFuel();
            }
            if (m_lives < 1)
            {
                gameState = GameState.gameOver;
            }
            if (gameState == GameState.takeOff)
            {
                foreach (Rocket rocket in m_rockets)
                {
                    if (!rocket.TakeOff())
                    {
                        m_level++;
                        gameState = GameState.nextLevel;
                    }
                }
            }
            if (gameState == GameState.nextLevel)
            {
                ResetLevel();
                gameState = GameState.gameOn;
            }

            //if (m_jetman.JetmanPosition.X > 400 || m_jetman.JetmanPosition.Y < 630) //   m_camera.CameraPos.X < 0)
            //{
            m_camera.Follow(m_jetman);
            //}

            base.Update(gameTime);
        }

        private void CheckBulletCollisions()
        {
            Bullet bulletToRemove = null;
            foreach (Enemy alien in m_enemies)
            {
                foreach (Bullet bullet in m_bullets)
                {
                    if (bullet.BulletRect.Intersects(alien.AlienRect))
                    {
                        m_explosion.Add(new Explosion(alien.AlienRect.X, alien.AlienRect.Y, m_explosionTexture));
                        alien.ResetMeteor();
                        died.Play();
                        bulletToRemove = bullet;
                        m_score += 100;
                        break;
                    }
                }
            }
            if (bulletToRemove != null)
            {
                m_bullets.Remove(bulletToRemove);
            }
        }

        private void CheckEnemyCollisions()
        {
            foreach (Enemy alien in m_enemies)
            {
                if (alien.AlienRect.Intersects(m_jetman.JetmanRect) && gameState == GameState.gameOn)
                {
                    m_explosion.Add(new Explosion(alien.AlienRect.X, alien.AlienRect.Y, m_explosionTexture));
                    alien.ResetMeteor();
                    died.Play();
                    m_lives--;
                    break;
                }

                foreach (Ledge ledge in m_ledge)
                {
                    if (alien.AlienRect.Intersects(ledge.LedgeRect))
                    {
                        m_explosion.Add(new Explosion(alien.AlienRect.X, alien.AlienRect.Y, m_explosionTexture));
                        alien.ResetMeteor();
                        hit.Play();
                    }
                }
            }
        }

        private void CheckBonusCollisions()
        {
            foreach (Bonus bonus in m_bonus)
            {
                foreach (Ledge ledge in m_ledge)
                {
                    if (bonus.BonRect.Intersects(ledge.LedgeRect))
                    {
                        bonus.BonusLanded = true;
                    }
                }

                if (m_jetman.JetmanRect.Intersects(bonus.BonRect))
                {
                    bonus.Reset();
                    m_score += 100;
                }
            }
        }

        private void CheckRocketCollsions()
        {
            if (m_jetman.JetmanRect.Intersects(m_rockets[1].RocketRect) && !m_firstSectionLowering)
            {
                if ((int)m_jetman.JetmanPosition.X != rocketLowerPosition)
                {
                    m_rockets[1].Update((int)m_jetman.JetmanPosition.X, (int)m_jetman.JetmanPosition.Y);
                }
                else
                {
                    m_firstSectionLowering = true;
                }
            }

            if (m_jetman.JetmanRect.Intersects(m_rockets[2].RocketRect) && m_firstSectionComplete && !m_secondSectionLowering)
            {
                if ((int)m_jetman.JetmanPosition.X != rocketLowerPosition)
                {
                    m_rockets[2].Update((int)m_jetman.JetmanPosition.X, (int)m_jetman.JetmanPosition.Y);
                }
                else
                {
                    m_secondSectionLowering = true;
                }
            }
        }

        //private void CheckJetManLedgeCollsions()
        //{
        //    foreach (Ledge ledge in m_ledge)
        //    {
        //        if (m_jetman.JetmanRect.Intersects(ledge.LedgeRect))
        //        {
        //            if (m_jetman.JetmanRect.Bottom - 3 == ledge.LedgeRect.Top ||
        //                m_jetman.JetmanRect.Bottom - 2 == ledge.LedgeRect.Top ||
        //                m_jetman.JetmanRect.Bottom - 1 == ledge.LedgeRect.Top)
        //            {
        //                y -= 1;
        //                m_onGround = true;
        //                if (!m_walking)
        //                {
        //                    m_currentFrame += 1;
        //                    m_walking = true;
        //                }
        //            }
        //            else
        //            {
        //                m_onGround = false;
        //            }
        //            if (m_jetman.JetmanRect.Top + 1 == ledge.LedgeRect.Bottom)
        //            {
        //                y += 2;
        //            }
        //            if (m_jetman.JetmanRect.Right - 2 == ledge.LedgeRect.Left)
        //            {
        //                x -= 2;
        //            }
        //            if (m_jetman.JetmanRect.Left + 1 == ledge.LedgeRect.Right)
        //            {
        //                x += 2;
        //            }
        //        }
        //    }
        //}

        private void CheckJetManLedgeCollsions(Tile tile) //Rectangle ledge)
        {
            m_wallCollsion = false;
            Rectangle ledge = tile.TileRect;
            if (m_jetman.JetmanRect.Intersects(tile.TileRect))
            {
                if (tile.GetTileCollisionType.Equals(TileCollisionType.Wall))
                //if (m_jetman.JetmanRect.Intersects(tile.TileRect))
                {
                    m_wallCollsion = true;

                    // Calculate half sizes.
                    float halfWidthA = ledge.Width / 2.0f;
                    float halfHeightA = ledge.Height;// / 2.0f;
                    float halfWidthB = m_jetman.JetmanRect.Width / 2.0f;
                    float halfHeightB = m_jetman.JetmanRect.Height;// / 2.0f;

                    // Calculate centers.
                    Vector2 centerA = new Vector2(ledge.Left + halfWidthA, ledge.Top + halfHeightA);
                    Vector2 centerB = new Vector2(m_jetman.JetmanRect.Left + halfWidthB, m_jetman.JetmanRect.Top + halfHeightB);

                    // Calculate current and minimum-non-intersecting distances between centers.
                    float distanceX = centerA.X - centerB.X;
                    float distanceY = centerA.Y - centerB.Y;
                    float minDistanceX = halfWidthA + halfWidthB;
                    float minDistanceY = halfHeightA + halfHeightB;

                    //// Calculate and return intersection depths.
                    float depthX = distanceX > 0 ? minDistanceX - distanceX : -minDistanceX - distanceX;
                    float depthY = distanceY > 0 ? minDistanceY - distanceY : -minDistanceY - distanceY;

                    if (depthX >= -2 && depthX <= 2)
                    {
                        m_wallCollsion = true;
                        x -= (int)Math.Ceiling(depthX) - 6;
                        x = 64;

                        if (centerA.X < centerB.X)
                        {
                            x = ledge.Right + 2;
                        }
                        if (centerA.X > centerB.X)
                        {
                            x = m_jetman.JetmanRect.Left - 4;
                        }
                    }

                    if (depthY < -50)
                    {
                        int i = 0;
                        y = m_jetman.JetmanRect.Top + 4;
                    }

                }
                if (tile.GetTileCollisionType.Equals(TileCollisionType.Platform))
                {
                    y = m_jetman.JetmanRect.Top - 4;
                }


                m_jetManPosition = new Vector2(x, y);
            }
            //            else {
            //               if (m_jetman.JetmanRect.Intersects(ledge))
            //               {
            //                   // Calculate the distance from the Man to the Ledge

            //                   // Calculate half sizes.
            //                   float halfWidthA = ledge.Width / 2.0f;
            //                   float halfHeightA = ledge.Height / 2.0f;
            //                   float halfWidthB = m_jetman.JetmanRect.Width / 2.0f;
            //                   float halfHeightB = m_jetman.JetmanRect.Height / 2.0f;

            //                   // Calculate centers.
            //                   Vector2 centerA = new Vector2(ledge.Left + halfWidthA, ledge.Top + halfHeightA);
            //                   Vector2 centerB = new Vector2(m_jetman.JetmanRect.Left + halfWidthB, m_jetman.JetmanRect.Top + halfHeightB);

            //                   // Calculate current and minimum-non-intersecting distances between centers.
            //                   float distanceX = centerA.X - centerB.X;
            //                   float distanceY = centerA.Y - centerB.Y;
            //                   float minDistanceX = halfWidthA + halfWidthB;
            //                   float minDistanceY = halfHeightA + halfHeightB;

            //                   // Calculate and return intersection depths.
            //                   float depthX = distanceX > 0 ? minDistanceX - distanceX : -minDistanceX - distanceX;
            //                   float depthY = distanceY > 0 ? minDistanceY - distanceY : -minDistanceY - distanceY;


            //                   if (depthX != 0)
            //                   {
            //                       m_wallCollsion = true;
            ////                       x -= (int)Math.Ceiling(depthX);
            //                   }

            //                   //if (depthY != 0)
            //                   //{
            //                   //    y -= (int)Math.Ceiling(depthY) - 2;
            //                   //    m_walking = true;
            //                   //}

            //                   //if (m_jetman.JetmanRect.Bottom - 3 == ledge.Top ||
            //                   //    m_jetman.JetmanRect.Bottom - 2 == ledge.Top ||
            //                   //    m_jetman.JetmanRect.Bottom - 1 == ledge.Top)
            //                   //{
            //                   //    y -= 1;
            //                   //    m_onGround = true;
            //                   //    if (!m_walking)
            //                   //    {
            //                   //        m_currentFrame += 1;
            //                   //        m_walking = true;
            //                   //    }
            //                   //}
            //                   //else
            //                   //{
            //                   //    m_onGround = false;
            //                   //}

            //                   //if (m_jetman.JetmanRect.Top + 4 == ledge.Bottom ||
            //                   //    m_jetman.JetmanRect.Top + 3 == ledge.Bottom ||
            //                   //    m_jetman.JetmanRect.Top + 2 == ledge.Bottom ||
            //                   //    m_jetman.JetmanRect.Top + 1 == ledge.Bottom)
            //                   //{
            //                   //    y += 2;
            //                   //}

            //                   //if (m_jetman.JetmanRect.Right - 4 == ledge.Left ||
            //                   //    m_jetman.JetmanRect.Right - 3 == ledge.Left ||
            //                   //    m_jetman.JetmanRect.Right - 2 == ledge.Left ||
            //                   //    m_jetman.JetmanRect.Right - 1 == ledge.Left)
            //                   //{
            //                   //    x -= 2;
            //                   //}

            //                   //if (m_jetman.JetmanRect.Left + 4 == ledge.Right ||
            //                   //    m_jetman.JetmanRect.Left + 3 == ledge.Right ||
            //                   //    m_jetman.JetmanRect.Left + 2 == ledge.Right ||
            //                   //    m_jetman.JetmanRect.Left + 1 == ledge.Right)
            //                   //{
            //                   //    x += 2;
            //                   //}
            //               }
            //           }
        }

        private void CheckFuelCollisions(Fuel fuel)
        {
            if (m_jetman.JetmanRect.Intersects(fuel.FuelRect))
            {
                if ((int)m_jetman.JetmanPosition.X != fuelLowerPosition && !m_fuelLowering)
                {
                    fuel.UpdatePosition((int)m_jetman.JetmanPosition.X, (int)m_jetman.JetmanPosition.Y);
                }
                else
                {
                    m_fuelLowering = true;
                }
            }
        }

        private void LowerRocketSections()
        {
            // Lower the first rocket section into place 
            if (m_firstSectionLowering && !m_firstSectionComplete)
            {
                m_firstSectionComplete = m_rockets[1].LowerSectionOne();
            }

            // Lower the first rocket section into place 
            if (m_secondSectionLowering && !m_secondSectionComplete)
            {
                m_secondSectionComplete = m_rockets[2].LowerSectionTwo();
            }

        }

        private void AddFuel()
        {
            m_fuel.Clear();
            if (m_fuelLevel != 100)
            {
                m_fuel.Add(new Fuel(m_fuelTexture));
            }
            else
            {
                gameState = GameState.takeOff;
                m_score += 100;
            }
        }

        private void CheckScreenBounds()
        {
            //if (y <= 50) { y = 50; }
            //if (y >= 861) { y = 861; }
            //if (x <= 0) { x = 0; }
            //if (x >= 750) { x = 750; }
        }

        //private void HorizontalScrollRight()
        //{
        //    if (x > 400 && x < 800 && m_srollX > -1000)
        //    {
        //        m_srollX -= 1;
        //        foreach (Ledge ledge in m_ledge)
        //        {
        //            ledge.Update(-2, 0);
        //        }
        //    }
        //}

        //private void HorizontalScrollLeft()
        //{
        //    if (x < 400 && x > -10 && m_srollX < 0)
        //    {
        //        m_srollX += 1;
        //        foreach (Ledge ledge in m_ledge)
        //        {
        //            ledge.Update(2, 0);
        //        }
        //    }
        //}

        //private void VerticalScrollDown()
        //{
        //    if (y > 300 && y < 600 && m_srollY > -1000)
        //    {
        //        m_srollY -= 1;
        //        foreach (Ledge ledge in m_ledge)
        //        {
        //            ledge.Update(0, -2);
        //        }
        //    }
        //}

        //private void VerticalScrollUp()
        //{
        //    if (y < 300 && y > 0 && m_srollY < 0)
        //    {
        //        m_srollY += 1;
        //        foreach (Ledge ledge in m_ledge)
        //        {
        //            ledge.Update(0, 2);
        //        }
        //    }
        //}

        private void CheckKeyboard()
        {
            int testX = 0;
            int testY = 0;
            if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed || Keyboard.GetState().IsKeyDown(Keys.Escape))
                Exit();

            if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed ||
                Keyboard.GetState().IsKeyDown(Keys.X))
            {
                if (gameState == GameState.gameOver)
                {
                    gameState = GameState.gameStart;
                    ResetGame();
                }
            }

            if (GamePad.GetState(PlayerIndex.One).DPad.Down == ButtonState.Pressed ||
            Keyboard.GetState().IsKeyDown(Keys.Down))
            {
                if (!m_onGround)
                {
                    //y += 2;
                    testY = 2;
                    CheckScreenBounds();
                    m_currentFrame = 0;
                }
            }

            if (GamePad.GetState(PlayerIndex.One).DPad.Up == ButtonState.Pressed ||
                Keyboard.GetState().IsKeyDown(Keys.Up))
            {
                //y -= 2;
                testY = -2;
                CheckScreenBounds();
                m_onGround = false;
                m_walking = false;
                m_currentFrame = 0;
            }

            if (GamePad.GetState(PlayerIndex.One).DPad.Left == ButtonState.Pressed ||
                Keyboard.GetState().IsKeyDown(Keys.Left))
            {
                flip = SpriteEffects.FlipHorizontally;
                if (!m_wallCollsion)
                {
//                    x -= 4;
                }
                testX = -4;
                m_animationTimer += m_elapsedCounter;
                CheckScreenBounds();
                if (m_onGround && m_animationTimer > 0.4)
                {
                    m_currentFrame = (m_currentFrame + 1) % 4;
                    if (m_currentFrame == 0) { m_currentFrame = 1; }
                    m_animationTimer = 0;
                }
            }

            if (GamePad.GetState(PlayerIndex.One).DPad.Right == ButtonState.Pressed ||
                Keyboard.GetState().IsKeyDown(Keys.Right))
            {
                flip = SpriteEffects.None;
                if (!m_wallCollsion)
                {
//                    x += 4;
                }
                testX = 4;
                m_animationTimer += m_elapsedCounter;
                CheckScreenBounds();
                if (m_onGround && m_animationTimer > 0.4)
                {
                    m_currentFrame = (m_currentFrame + 1) % 4;
                    if (m_currentFrame == 0) { m_currentFrame = 1; }
                    m_animationTimer = 0;
                }
            }

            if (GamePad.GetState(PlayerIndex.One).Buttons.LeftShoulder == ButtonState.Pressed ||
                Keyboard.GetState().IsKeyDown(Keys.LeftControl))
            {
                fire.Play();
                m_delayCounter += m_elapsedCounter;
                if (m_delayCounter > 0.4)
                {
                    if (flip == SpriteEffects.None)
                    {
                        m_bullets.Add(new Bullet(x, m_jetman.JetmanRect.Center.Y/*   m_jetmanTexture.Height / 2 + y*/, m_bulletTexture, false));
                    }
                    else
                    {
                        m_bullets.Add(new Bullet(x, m_jetman.JetmanRect.Center.Y /*m_jetmanTexture.Height / 2 + y*/, m_bulletTexture, true));
                    }
                    m_delayCounter = 0;
                }
            }

            if (Keyboard.GetState().IsKeyDown(Keys.A)) { m_drawnWithLighting = true; }
            if (Keyboard.GetState().IsKeyDown(Keys.S)) { m_drawnWithLighting = false; }


            m_jetman.JetmanAnimFrame = m_currentFrame;
            //m_jetManPosition = new Vector2(x, y);
            float floaterX = x += (int)getVelocityX(testX);
            float floaterY = y += (int)getVelocityY(testY);
            m_jetManPosition = new Vector2(floaterX, floaterY);
            //m_jetman.Update(x, y, flip);
            m_jetman.Update(m_jetManPosition, flip);
        }


        /**
         * 
         *     public void update(float speed, float[] scroll, boolean walking, List<Tile> floorsActive) {
         *       float velocityX = 0;
         *       if (speed != 0) {
         *       velocityX = getVelocityX(speed, floorsActive);
         *       }
         * 
         * 
         * ////            // Check the number of pixels we are away from a rectangle collision
         * ////            for (float increment = 0; increment < 7; increment++) {
         * ////                velocityY += checkForVerticalIntersections(increment, playerRectangle, floorsActive);
         * ////            }
         * 
         */


        /**
        * Method to check 1 pixel by pixel incremental horizontal collision detection
        * @param increment
        * @param playerRectangle
        * @param tileList
        * @return
        */
        private float checkForHorizontalIntersections(float increment)
        {
            // Create a new Rectangle based on the players current position for testing Rectangle overlaps
            Rectangle testRect = new Rectangle((int)(m_jetman.JetmanPosition.X + increment), (int)m_jetman.JetmanPosition.Y, m_jetman.JetmanRect.Width, m_jetman.JetmanRect.Height - 5);
            foreach (Tile tile in m_graphicsManager.TileList)
            {
                if (testRect.Intersects(tile.TileRect))
                {
                    return 0;
                }
            }
            return increment;
        }


        /**
         * Method to check 1 pixel by pixel incremental vertical collision detection
         * @param increment  Incremental per pixel value
         * @param playerRectangle  Players Rectangle
         * @param tileList    List of tiles used to check against
         * @return
         */
        
        private float checkForVerticalIntersections(float increment) //, Rectangle playerRectangle, List<Tile> tileList)
        {
            // Create a new Rectangle based on the players current position for testing
            Rectangle testRect = new Rectangle((int)m_jetman.JetmanPosition.X, (int)(m_jetman.JetmanPosition.Y + increment), m_jetman.JetmanRect.Width, m_jetman.JetmanRect.Height - 5);
            foreach (Tile tile in m_graphicsManager.TileList)
            {
                if (testRect.Intersects(tile.TileRect))
                {
                    return 0;
                }
            }
            return increment;
        }
        

        /**
         * This method executes a loop determined by the speed variable:
         * +ve or -ve to check if a rectangle intersection would occur.
         * This method returns the number of pixels that the player can move based on the speed and if a collision occurs,
         * i.e. If the speed is (-/+ve) 2 & no collision occurs the returned value would
         *
         * @param speed
         * @param floorsActive
         * @return
         */
        public float getVelocityX(float speed) //, List<Tile> floorsActive)
        {
            float pixelMovement = 0;
            int pixels = 0;
            if (speed != 0)
            {
                if (speed > 0)
                {
                    for (float increment = 0; increment < speed; increment++)
                    {
                        //                       pixelMovement = checkForHorizontalIntersections(++pixels, playerRectangle, floorsActive);
                        pixelMovement = checkForHorizontalIntersections(++pixels);
                    }
                }
                else if (speed < 0)
                {
                    pixels = 0;
                    for (float increment = 0; increment > speed; increment--)
                    {
                        //                       pixelMovement = checkForHorizontalIntersections(--pixels, playerRectangle, floorsActive);
                        pixelMovement = checkForHorizontalIntersections(--pixels);
                    }
                }
            }
            return pixelMovement;
        }


        /**
         * This method executes a loop determined by the speed variable:
         * +ve or -ve to check if a rectangle intersection would occur.
         * This method returns the number of pixels that the player can move based on the speed and if a collision occurs,
         * i.e. If the speed is (-/+ve) 2 & no collision occurs the returned value would
         *
         * @param speed
         * @param floorsActive
         * @return
         */
        public float getVelocityY(float speed)
        {
            float pixelMovement = 0;
            int pixels = 0;
            if (speed != 0)
            {
                if (speed > 0)
                {
                    for (float increment = 0; increment < speed; increment++)
                    {
                        pixelMovement = checkForVerticalIntersections(++pixels);//, playerRectangle, floorsActive);
                    }
                }
                else if (speed < 0)
                {
                    pixels = 0;
                    for (float increment = 0; increment > speed; increment--)
                    {
                        pixelMovement = checkForVerticalIntersections(--pixels);//, playerRectangle, floorsActive);
                    }
                }
            }
            return pixelMovement;
        }



        private void ResetGame()
        {
            m_score = 0;
            m_lives = 3;
            m_level = 0;
            m_fuelLevel = 0;
            m_currentFrame = 0;
            x = 150;
            y = 300;
            ResetLevel();
        }

        private void ResetLevel()
        {
            x = 150;
            y = 300;
            m_rocket1X = 422;
            m_rocket1Y = 443;
            m_rocket2X = 110;
            m_rocket2Y = 139;
            m_rocket3X = 510;
            m_rocket3Y = 75;
            m_fuelLevel = 0;
            m_fuelAdded = false;
            m_fuelLowering = false;
            m_firstSectionLowering = false;
            m_firstSectionComplete = false;
            m_secondSectionLowering = false;
            m_secondSectionComplete = false;
            rocketLocation1 = new Vector2(m_rocket1X, m_rocket1Y);
            rocketLocation2 = new Vector2(m_rocket2X, m_rocket2Y);
            rocketLocation3 = new Vector2(m_rocket3X, m_rocket3Y);
            m_rockets.Clear();
            int frame = m_level % 4;
            m_rockets.Add(new Rocket((int)rocketLocation1.X, (int)rocketLocation1.Y, m_rocketTexture, frame, 75, 61));
            m_rockets.Add(new Rocket((int)rocketLocation2.X, (int)rocketLocation2.Y, m_rocketTexture, frame + 4, 75, 61));
            m_rockets.Add(new Rocket((int)rocketLocation3.X, (int)rocketLocation3.Y, m_rocketTexture, frame + 8, 75, 61));
            foreach (Enemy alien in m_enemies)
            {
                alien.ResetMeteor();
            }

        }

        protected override void Draw(GameTime gameTime)
        {
            GraphicsDevice.Clear(Color.Black);

            if (gameState == GameState.gameOver)
            {
                m_spriteBatch.Begin();
                m_spriteBatch.Draw(m_menuTexture, new Vector2(0, 0), Color.White);
                m_spriteBatch.DrawString(m_font, "JetPac the Remake (Monogame Update)", new Vector2(150.0f, 440.0f), Color.Yellow);
                m_spriteBatch.DrawString(m_font, "Written by Ian Wigley", new Vector2(150.0f, 460.0f), Color.Yellow);
                m_spriteBatch.DrawString(m_font, "In 2020", new Vector2(150.0f, 480.0f), Color.Yellow);
                m_spriteBatch.DrawString(m_font, "Press X to start", new Vector2(150.0f, 520.0f), Color.Yellow);
                m_spriteBatch.End();
            }
            else
            {
                if (m_drawnWithLighting)
                {
                    // Create a Light Mask to pass to the pixel shader
                    GraphicsDevice.SetRenderTarget(lightsTarget);
                    GraphicsDevice.Clear(Color.Black);
                    m_spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.Additive, transformMatrix: m_camera.Transform);
                    m_spriteBatch.Draw(jetmanMask, new Vector2(x - 280, y - 280), Color.White);
                    //m_spriteBatch.Draw(lightMask, new Vector2(100, 0), Color.White);
                    m_spriteBatch.Draw(lightMask, new Vector2(160, 100), Color.White);
                    m_spriteBatch.Draw(lightMask, new Vector2(590, 100), Color.White);
                    //m_spriteBatch.Draw(lightMask, new Vector2(500, 200), Color.White);
                    m_spriteBatch.End();

                    // Draw the main scene to the Render Target
                    GraphicsDevice.SetRenderTarget(mainTarget);
                }

                //https://www.youtube.com/watch?v=ceBCDKU_mNw
                m_spriteBatch.Begin(transformMatrix: m_camera.Transform);

                m_spriteBatch.Draw(m_rustyTexture, new Vector2(0, 0), Color.White);





                m_graphicsManager.TileList.ForEach(i =>
                {
                    if (i.Drawable(x, y))
                    {
                        m_spriteBatch.Draw(_texture, i.TileRect, i.TileTexture, Color.White);
                        m_spriteBatch.Draw(undergroundTiles, i.TileRect, i.TileTexture, Color.White);
                    }
                });

                foreach (Star star in m_stars)
                {
                    star.Draw(m_spriteBatch);
                }

                foreach (Enemy alien in m_enemies)
                {
                    alien.Draw(m_spriteBatch);
                }

                foreach (Explosion explosion in m_explosion)
                {
                    explosion.Draw(m_spriteBatch);
                }

                foreach (Bullet bullet in m_bullets)
                {
                    bullet.Draw(m_spriteBatch);
                }

                foreach (Fuel fuel in m_fuel)
                {
                    fuel.Draw(m_spriteBatch);
                }

                foreach (Bonus bonus in m_bonus)
                {
                    bonus.Draw(m_spriteBatch);
                }

                foreach (Rocket rocket in m_rockets)
                {
                    rocket.Draw(m_spriteBatch);
                }

                foreach (Ledge ledge in m_ledge)
                {
                    ledge.Draw(m_spriteBatch);
                }



                m_jetman.Draw(m_spriteBatch);



                m_spriteBatch.End();

                foreach (Particle particle in m_particles)
                {
                    particle.Draw(m_spriteBatch, m_camera);
                }


                if (m_drawnWithLighting)
                {
                    // Draw the main scene with a pixel
                    GraphicsDevice.SetRenderTarget(null);
                    GraphicsDevice.Clear(Color.CornflowerBlue);
                    m_spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.AlphaBlend);
                    lightingEffect.Parameters["lightMask"].SetValue(lightsTarget);
                    lightingEffect.CurrentTechnique.Passes[0].Apply();
                    m_spriteBatch.Draw(mainTarget, Vector2.Zero, Color.White);
                    m_spriteBatch.End();
                }

                m_spriteBatch.Begin();
                m_spriteBatch.DrawString(m_font, "SCORE : " + m_score.ToString("D4"), scoreLocation + new Vector2(1.0f, 1.0f), Color.Yellow);
                m_spriteBatch.DrawString(m_font, "FUEL : " + m_fuelLevel + "%", scoreLocation + new Vector2(350.0f, 1.0f), Color.Yellow);
                m_spriteBatch.DrawString(m_font, "LIVES : " + m_lives, scoreLocation + new Vector2(700.0f, 1.0f), Color.Yellow);

                m_spriteBatch.DrawString(m_font, "x : " + x + " y : " + y, scoreLocation + new Vector2(1.0f, 15.0f), Color.Yellow);
                m_spriteBatch.DrawString(m_font, "x scroll : " + m_srollX + " y scroll : " + m_srollY, scoreLocation + new Vector2(1.0f, 30.0f), Color.Yellow);
                m_spriteBatch.DrawString(m_font, "x camera : " + m_camera.CameraPos.X + " y camera : " + m_camera.CameraPos.Y, scoreLocation + new Vector2(1.0f, 45.0f), Color.Yellow);
                m_spriteBatch.DrawString(m_font, "x : " + m_jetman.JetmanRect.X + " y : " + m_jetman.JetmanRect.Y, scoreLocation + new Vector2(1.0f, 60.0f), Color.Yellow);
                //m_spriteBatch.DrawString(m_font, "m_onGround: " + m_onGround, scoreLocation + new Vector2(1.0f, 25.0f), Color.Yellow);



                m_spriteBatch.End();
            }

            base.Draw(gameTime);
        }
    }
}
