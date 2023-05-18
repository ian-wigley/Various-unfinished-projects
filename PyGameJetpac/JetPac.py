# /////////////////////////////////////////////////////////
# //         JetPac - Written by Ian Wigley              //
# //            Pygame re-write Nov 2020                 //
# //    Static values removed & general code clean up    //
# //        Project migrated to Python & Pygame          //
# /////////////////////////////////////////////////////////

import pygame
import sys
from pygame.locals import *
from Bonus import bonus
from Bullet import bullet
from Enemy import enemy
from Explosion import explosion
from Fuel import fuel
from Jetman import jetman
from Ledge import ledge
from Rocket import rocket
from StarLayerOne import starlayerone
from Particle import particle
from Gamestate import GameState


class JetPac:
    def __init__(self):
        # https://www.youtube.com/watch?v=Q-__8Xw9KTM
        self.py = pygame.init()
        pygame.init()
        pygame.font.init()
        pygame.display.set_caption("JetPac")
        self.FPS = 120  # frames per second setting
        self.fps_clock = pygame.time.Clock()
        self.size = width, height = 800, 600
        #self.screen = pygame.display.set_mode(self.size)
        self.screen = pygame.display.set_mode((800,600))

        self.game_on = True

        self.m_rocket1X = 422
        self.m_rocket1Y = 443
        self.m_rocket2X = 110
        self.m_rocket2Y = 139
        self.m_rocket3X = 510
        self.m_rocket3Y = 75
        self.m_score = 0
        self.m_lives = 3
        self.m_level = 0
        self.m_fuel_level = 0
        self.m_current_frame = 0
        self.m_rocket_lower_position = 422
        self.m_fuel_lower_position = 430

        self.game_state = GameState.GAME_OVER.value

        #         private SoundEffect died;
        #         private SoundEffect fire;
        #         private SoundEffect hit;

        self.m_score_location = pygame.Vector2(11.0, 11.0)
        self.m_rocket_location_1 = None
        self.m_rocket_location_2 = None
        self.m_rocket_location_3 = None

        self.m_flip = "right"

        self.m_on_ground = False
        self.m_fuel_added = False
        self.m_fuel_lowering = False
        self.m_walking = False

        self.m_first_section_lowering = False
        self.m_first_section_complete = False
        self.m_second_section_lowering = False
        self.m_second_section_complete = False

        self.m_animation_timer = 0
        self.m_game_starting_delay = 0
        self.m_delay_counter = 0
        self.m_elapsed_counter = 0.1

        self.m_enemies = []
        self.m_stars = []
        self.m_particles = []
        self.m_bullets = []
        self.m_rockets = []
        self.m_fuel = []
        self.m_ledges = []
        self.m_bonus = []
        self.m_explosion = []

        self.master_list = []
        self.master_rects = []

    def load_images(self):

        self.bonus_images = pygame.image.load("Images/bonus.png").convert_alpha()
        self.bullet_image = pygame.image.load("Images/bullet.png").convert_alpha()
        self.explosion_images = pygame.image.load("Images/explosion.png").convert_alpha()
        self.m_floor_texture = pygame.image.load("Images/floor.png").convert_alpha()
        self.fuel_cell_image = pygame.image.load("Images/fuel_cell.png").convert_alpha()
        self.jetman_images = pygame.image.load("Images/sprites.png").convert_alpha()
        self.m_ledge_1_texture = pygame.image.load("Images/ledge1.png").convert_alpha()
        self.m_ledge_2_texture = pygame.image.load("Images/ledge2.png").convert_alpha()
        self.loading_image = pygame.image.load("Images/loading.png").convert_alpha()
        self.meteor_images = pygame.image.load("Images/meteor.png").convert_alpha()
        self.particle_image = pygame.image.load("Images/particle.png").convert_alpha()
        self.rocket_images = pygame.image.load("Images/rocket_sprites.png").convert_alpha()
        self.star_image = pygame.image.load("Images/star.png").convert_alpha()

        self.jet_man = jetman(200, 200, pygame.Vector2(200, 200), self.jetman_images)

        # self.m_rockets.append(rocket(0, 0, pygame.Vector2(422, 443), self.rocket_images, 0, 75, 61))
        # self.m_rockets.append(rocket(0, 0, pygame.Vector2(110, 139), self.rocket_images, 4, 75, 61))
        # self.m_rockets.append(rocket(0, 0, pygame.Vector2(510, 75), self.rocket_images, 8, 75, 61))

        # for x in range(20):
        #     self.master_list.append(starlayerone(image=self.star_image))
        #     #m_particles.Add(new Particle(m_particleTexture));
        for x in range(5):
            self.master_list.append(enemy(0, 0, pygame.Vector2(422, 443), self.meteor_images, 0, 0, 0))

        self.master_list.append(ledge(0, 0, pygame.Vector2(60, 200), self.m_ledge_1_texture, 0, 0, 0))
        self.master_list.append(ledge(0, 0, pygame.Vector2(310, 265), self.m_ledge_2_texture, 0, 0, 0))
        self.master_list.append(ledge(0, 0, pygame.Vector2(490, 136), self.m_ledge_1_texture, 0, 0, 0))
        self.master_list.append(ledge(0, 0, pygame.Vector2(0, 500), self.m_floor_texture, 0, 0, 0))
        self.master_list.append(bonus(0, 0, pygame.Vector2(0, 0), self.bonus_images, 0, 0, 0))

        self.myfont = pygame.font.SysFont("Comic Sans MS", 15)
        self.textsurface = self.myfont.render("Score : 0000", False, (100, 100, 100))

    def main(self):
        pygame.key.set_repeat(10, 10)
        while self.game_on:
            self.check_keys()
            self.update()
            self.draw()
            self.fps_clock.tick(60)
            pygame.display.update()

    def update(self):

        # if self.game_state == GameState.GAME_START.value:
        #     self.m_game_starting_delay += self.m_elapsed_counter
        #     if self.m_game_starting_delay > 10:
        #         self.game_state = GameState.GAME_ON.value
        # # elif self.game_state == GameState.GAME_ON.value:

        # for particle in self.m_particles:
        # self.jet_man.m_y += 1

        for star in self.m_stars:
            star.update()

        # master_rects ? is used for collision detection
        self.master_rects = []
        for obj in self.master_list:
            # if obj.type != 'enemy':
            obj.update()
            # else:
            # obj.update(self.m_level)
        #            self.master_rects.append(obj.get_rect())

        #        for enemy in self.m_enemies:
        #            enemy.update(self.m_level)

        temp_bullet = []
        for bullet in self.m_bullets:
            if not bullet.offscreen():
                bullet.update()
                temp_bullet.append(bullet)
        self.m_bullets = temp_bullet

        # temp_explosion = []
        # for explosion in self.m_explosion:
        #     if not explosion.AnimationComplete():
        #         explosion.Update()
        #         temp_explosion.append(explosion)
        # self.m_explosion = temp_explosion

        # # for bonus in self.m_bonus:
        # #     bonus.Update()

        # self.check_rocket_collsions()
        # self.lower_rocket_sections()
        # self.check_bullet_collisions()
        # self.check_enemy_collisions()
        # self.check_bonus_collisions()
        # self.check_jetman_ledge_collsions()

        # #             foreach (Particle particle in m_particles)
        # #             {
        # #                 if (m_fuel_level < 100)
        # #                 {
        # #                     particle.Update(x, y, m_flip != SpriteEffects.None, !m_onGround);
        # #                 }
        # #                 else
        # #                 {
        # #                     particle.Update(m_rocket_lower_position + 36, m_rockets[0].RocketRect.Y + 36, false, true);
        # #                 }
        # #             }

        # if self.m_second_section_complete and not self.m_fuel_added:
        #     self.AddFuel()
        #     self.m_fuel_added = True

        # next_fuel = False
        # for fuel in self.m_fuel:
        #     fuel.Update(self.m_ledges)
        #     self.CheckFuelCollisions(fuel)
        #     if self.m_fuel_lowering:
        #         if fuel.LowerFuel():
        #             if self.m_fuel_level < 100:
        #                 self.m_fuel_level += 25
        #                 self.m_fuel_lowering = False
        #                 next_fuel = True
        # if next_fuel:
        #     self.AddFuel()
        # if self.m_lives < 1:
        #     self.game_state = GameState.GAME_OVER.value
        # if self.game_state == GameState.TAKE_OFF.value:
        #     for rocket in self.m_rockets:
        #         if not rocket.TakeOff():
        #             self.m_level += 1
        #             self.game_state = GameState.NEXT_LEVEL.value
        # if self.game_state == GameState.NEXT_LEVEL.value:
        #     self.ResetLevel()
        #     self.game_state = GameState.GAME_ON.value

    def draw(self):
        if self.game_on:

            self.screen.fill((0, 0, 0))

            if self.game_state == GameState.GAME_OVER.value:
                # self.screen.blit(self.textsurface,(100,100))
                self.screen.blit(
                    self.loading_image,
                    pygame.Vector2(0, 0),
                    pygame.Rect(
                        0,
                        0,
                        self.loading_image.get_width(),
                        self.loading_image.get_height(),
                    ),
                )
                intro_text_one = self.myfont.render(
                    "JetPac Remake (Pygame Version)", False, (100, 100, 100)
                )
                self.screen.blit(intro_text_one, (150, 440))
                intro_text_two = self.myfont.render(
                    "Written by Ian Wigley", False, (100, 100, 100)
                )
                self.screen.blit(intro_text_two, (150, 460))
                intro_text_three = self.myfont.render(
                    "In 2021", False, (100, 100, 100)
                )
                self.screen.blit(intro_text_three, (150, 480))
                intro_text_four = self.myfont.render(
                    "Press X to start", False, (0, 155, 255)
                )
                self.screen.blit(intro_text_four, (150, 520))
                pygame.display.update()
            else:
                score_text = self.myfont.render(
                    "Score : " + str(self.m_score), False, (100, 100, 100)
                )
                self.screen.blit(score_text, (100, 10))
                fuel_text = self.myfont.render(
                    "Fuel : " + str(self.m_fuel_level) + "%", False, (100, 100, 100)
                )
                self.screen.blit(fuel_text, (350, 10))
                lives_text = self.myfont.render(
                    "Lives : " + str(self.m_lives), False, (100, 100, 100)
                )
                self.screen.blit(lives_text, (600, 10))

                # self.textsurface = self.myfont.render(
                #     "X : " + (str)(self.jet_man.m_x), False, (100, 100, 100)
                # )
                # self.screen.blit(self.textsurface, (100, 30))
                # # m_spriteBatch.DrawString(m_font, "SCORE : " + m_score.ToString("D4"), m_score_location, Color.Yellow);
                # # m_spriteBatch.DrawString(m_font, "FUEL : " + m_fuel_level + "%", m_score_location + new Vector2(350.0f, 1.0f), Color.Yellow);
                # # m_spriteBatch.DrawString(m_font, "LIVES : " + m_lives, m_score_location + new Vector2(700.0f, 1.0f), Color.Yellow);

                # # for star in self.m_stars:
                # #     star.draw(self.screen)

                # # for enemy in self.m_enemies:
                # #     enemy.draw(self.screen)

                # # for explosion in self.m_explosion:
                # #     explosion.draw(self.screen)

                for bullet in self.m_bullets:
                    bullet.draw(self.screen)

                # # for fuel in self.m_fuel:
                # #     fuel.draw(self.screen)

                # # # for bonus in self.m_bonus:
                # # #     bonus.draw(self.screen)

                for obj in self.master_list:
                    obj.draw(self.screen)

                for rocket in self.m_rockets:
                    rocket.draw(self.screen)

                self.jet_man.draw(self.screen, self.m_flip)

                # for particle in self.m_particles:
                #   particle.draw(self.screen)

                # pygame.display.update()  # self.master_rects)
                # pygame.display.update(self.master_rects)

            #pygame.display.flip()
            #pygame.display.update()
            #pygame.time.delay(10)

    def check_keys(self):
        for event in pygame.event.get():
            # if event.type == pygame.KEYDOWN:
            if event.type == pygame.QUIT:
                self.game_on = False
                pygame.quit()
                sys.exit()

            if event.type == KEYDOWN:
                #             if (GamePad.GetState(PlayerIndex.One).Buttons.Back == ButtonState.Pressed || Keyboard.GetState().IsKeyDown(Keys.Escape))
                #             {
                #                 Exit();
                #             }
                if (event.key == pygame.K_x and self.game_state == GameState.GAME_OVER.value):
                    #             if (GamePad.GetState(PlayerIndex.One).Buttons.Start == ButtonState.Pressed ||
                    #                 Keyboard.GetState().IsKeyDown(Keys.X))
                    #             {
                    # if (self.game_state == GameState.GAME_OVER.value):
                    self.game_state = GameState.GAME_START.value
                    self.reset_game()
                #                     gameState = GameState.gameStart;
                #                     ResetGame();
                #                 }
                #             }

                if event.key == pygame.K_RIGHT:
                    #             if (GamePad.GetState(PlayerIndex.One).DPad.Right == ButtonState.Pressed ||
                    #                 Keyboard.GetState().IsKeyDown(Keys.Right))
                    #             {
                    #                 m_flip = SpriteEffects.None;
                    #                 x += 2;
                    #                 m_animation_timer += m_elapsed_counter;
                    #                 CheckScreenBounds();
                    #                 if (m_onGround && m_animation_timer > 0.4)
                    #                 {
                    #                     m_current_frame = (m_current_frame + 1) % 4;
                    #                     if (m_current_frame == 0) { m_current_frame = 1; }
                    #                     m_animation_timer = 0;
                    #                 }
                    #             }
                    self.jet_man.m_x += 2
                    self.m_flip = "right"
                elif event.key == pygame.K_LEFT:
                    #             if (GamePad.GetState(PlayerIndex.One).DPad.Left == ButtonState.Pressed ||
                    #                 Keyboard.GetState().IsKeyDown(Keys.Left))
                    #             {
                    #                 m_flip = SpriteEffects.m_flipHorizontally;
                    #                 x -= 2;
                    #                 m_animation_timer += m_elapsed_counter;
                    #                 CheckScreenBounds();
                    #                 if (m_onGround && m_animation_timer > 0.4)
                    #                 {
                    #                     m_current_frame = (m_current_frame + 1) % 4;
                    #                     if (m_current_frame == 0) { m_current_frame = 1; }
                    #                     m_animation_timer = 0;
                    #                 }
                    #             }
                    self.jet_man.m_x -= 2
                    self.m_flip = "left"
                elif event.key == pygame.K_DOWN:
                    #             if (GamePad.GetState(PlayerIndex.One).DPad.Down == ButtonState.Pressed ||
                    #             Keyboard.GetState().IsKeyDown(Keys.Down))
                    #             {
                    #                 if (!m_onGround)
                    #                 {
                    #                     y += 2;
                    #                     CheckScreenBounds();
                    #                     m_current_frame = 0;
                    #                 }
                    #             }
                    if not self.m_on_ground:
                        self.jet_man.m_y += 2
                        self.check_screen_bounds()
                        self.m_current_frame = 0
                elif event.key == pygame.K_UP:
                    #             if (GamePad.GetState(PlayerIndex.One).DPad.Up == ButtonState.Pressed ||
                    #                 Keyboard.GetState().IsKeyDown(Keys.Up))
                    #             {
                    #                 y -= 2;
                    #                 CheckScreenBounds();
                    #                 m_onGround = false;
                    #                 m_walking = false;
                    #                 m_current_frame = 0;
                    #             }
                    self.jet_man.m_y -= 2
                    self.check_screen_bounds()
                    self.m_on_ground = False
                    self.m_walking = False
                    self.m_current_frame = 0
                    self.jet_man.m_y -= 1
                elif event.key == pygame.K_LCTRL:
                    # fire.Play()
                    self.m_delay_counter += self.m_elapsed_counter
                    if self.m_delay_counter > 0.4:
                        if self.m_flip == "right":
                            self.m_bullets.append(
                                bullet(
                                    0,
                                    0,
                                    pygame.Vector2(
                                        self.jet_man.m_x,
                                        self.jetman_images.get_height() / 4
                                        + self.jet_man.m_y,
                                    ),
                                    self.bullet_image,
                                    0,
                                    self.jetman_images.get_width(),
                                    self.jetman_images.get_height(),
                                    False,
                                )
                            )
                        else:
                            self.m_bullets.append(
                                bullet(
                                    0,
                                    0,
                                    pygame.Vector2(
                                        self.jet_man.m_x,
                                        self.jetman_images.get_height() / 4
                                        + self.jet_man.m_y,
                                    ),
                                    self.bullet_image,
                                    0,
                                    self.jetman_images.get_width(),
                                    self.jetman_images.get_height(),
                                    True,
                                )
                            )
                        self.m_delay_counter = 0

            self.jet_man.m_frame = self.m_current_frame

    #             m_jetman.Update(x, y, m_flip);

    def check_bullet_collisions(self):
        bullet_to_remove = None
        for bullet in self.m_bullets:
            for alien in self.m_enemies:
                if bullet.get_rect().colliderect(alien.get_rect()):
                    self.m_explosion.append(
                        explosion(
                            0,
                            0,
                            pygame.Vector2(alien.get_rect().x, alien.get_rect().y),
                            self.explosion_images,
                            0,
                            0,
                            0,
                        )
                    )
                    alien.reset_enemy()
                    # died.Play()
                    bullet_to_remove = bullet
                    self.m_score += 100
                    break
        if bullet_to_remove != None:
            self.m_bullets.remove(bullet_to_remove)

    def check_enemy_collisions(self):
        for alien in self.m_enemies:
            if (
                alien.get_rect().colliderect(self.jet_man.JetmanRect())
                and self.game_state == GameState.GAME_ON.value
            ):
                self.m_explosion.append(
                    explosion(
                        0,
                        0,
                        pygame.Vector2(alien.get_rect().x, alien.get_rect().y),
                        self.explosion_images,
                        0,
                        0,
                        0,
                    )
                )
                alien.reset_enemy()
                # died.Play()
                self.m_lives -= 1
                break
            for ledge in self.m_ledges:
                if alien.get_rect().colliderect(ledge.get_rect()):
                    self.m_explosion.append(
                        explosion(
                            0,
                            0,
                            pygame.Vector2(alien.get_rect().x, alien.get_rect().y),
                            self.explosion_images,
                            0,
                            0,
                            0,
                        )
                    )
                    alien.reset_enemy()
                    # hit.Play()

    def check_bonus_collisions(self):
        for bonus in self.m_bonus:
            for ledge in self.m_ledges:
                if bonus.BonRect().colliderect(ledge.LedgeRect()):
                    bonus.bonus_landed(True)
                if self.jet_man.JetmanRect().colliderect(bonus.BonRect()):
                    bonus.Reset()
                    self.m_score += 100

    def check_rocket_collsions(self):
        if (
            self.jet_man.JetmanRect().colliderect(self.m_rockets[1].RocketRect())
            and not self.m_first_section_lowering
        ):
            if self.jet_man.m_x != self.m_rocket_lower_position:
                self.m_rockets[1].Update(self.jet_man.m_x, self.jet_man.m_y)
            else:
                self.m_first_section_lowering = True

        if (
            self.jet_man.JetmanRect().colliderect(self.m_rockets[2].RocketRect())
            and self.m_first_section_complete
            and not self.m_second_section_lowering
        ):
            if self.jet_man.m_x != self.m_rocket_lower_position:
                self.m_rockets[2].Update(self.jet_man.m_x, self.jet_man.m_y)
            else:
                self.m_second_section_lowering = True

    def check_jetman_ledge_collsions(self):
        for ledge in self.m_ledges:
            if self.jet_man.JetmanRect().colliderect(ledge.LedgeRect()):
                if (
                    self.jet_man.JetmanRect().bottom - 3 == ledge.LedgeRect().top
                    or self.jet_man.JetmanRect().bottom - 2 == ledge.LedgeRect().top
                    or self.jet_man.JetmanRect().bottom - 1 == ledge.LedgeRect().top
                ):

                    self.jet_man.m_y -= 1
                    self.m_on_ground = True

                    if not self.m_walking:
                        self.m_current_frame += 1
                        self.m_walking = True
                else:
                    self.m_on_ground = False

                if self.jet_man.JetmanRect().top + 1 == ledge.LedgeRect().bottom:
                    self.jet_man.m_y += 2

                if self.jet_man.JetmanRect().right - 2 == ledge.LedgeRect().left:
                    self.jet_man.m_x -= 2

                if self.jet_man.JetmanRect().left + 1 == ledge.LedgeRect().right:
                    self.jet_man.m_x += 2

    def check_fuel_collisions(self, fuel):
        if self.jet_man.JetmanRect().colliderect(fuel.FuelRect()):
            if (
                self.jet_man.m_x != self.m_fuel_lower_position
                and not self.m_fuel_lowering
            ):
                fuel.UpdatePosition(self.jet_man.m_x, self.jet_man.m_y)
            else:
                self.m_fuel_lowering = True

    def lower_rocket_sections(self):
        # Lower the first rocket section into place
        if self.m_first_section_lowering and not self.m_first_section_complete:
            self.m_first_section_complete = self.m_rockets[1].LowerSectionOne()
        # Lower the second rocket section into place
        if self.m_second_section_lowering and not self.m_second_section_complete:
            self.m_second_section_complete = self.m_rockets[2].LowerSectionTwo()

    def add_fuel(self):
        self.m_fuel = []
        if self.m_fuel_level != 100:
            self.m_fuel.append(
                fuel(0, 0, pygame.Vector2(0, 0), self.fuel_cell_image, 0, 0, 0)
            )
        else:
            self.game_state = GameState.TAKE_OFF.value
            self.m_score += 100

    def check_screen_bounds(self):
        if self.jet_man.m_y <= 50:
            self.jet_man.m_y = 50
        if self.jet_man.m_y >= 550:
            self.jet_man.m_y = 550

        if self.jet_man.m_x <= 0:
            self.jet_man.m_x = 0
        if self.jet_man.m_x >= 750:
            self.jet_man.m_x = 750

    def reset_game(self):
        self.m_score = 0
        self.m_lives = 3
        self.m_level = 0
        self.m_fuel_level = 0
        self.m_current_frame = 0
        self.x = 150
        self.y = 300
        self.reset_level()

    def reset_level(self):
        self.x = 150
        self.y = 300
        self.m_rocket1X = 422
        self.m_rocket1Y = 443
        self.m_rocket2X = 110
        self.m_rocket2Y = 139
        self.m_rocket3X = 510
        self.m_rocket3Y = 75
        self.m_fuel_level = 0
        self.m_fuelAdded = False
        self.m_fuel_lowering = False
        self.m_first_section_lowering = False
        self.m_first_section_complete = False
        self.m_second_section_lowering = False
        self.m_second_section_complete = False
        self.m_rocket_location_1 = pygame.Vector2(self.m_rocket1X, self.m_rocket1Y)
        self.m_rocket_location_2 = pygame.Vector2(self.m_rocket2X, self.m_rocket2Y)
        self.m_rocket_location_3 = pygame.Vector2(self.m_rocket3X, self.m_rocket3Y)
        self.m_rockets = []
        frame = self.m_level % 4
        # # self.m_rockets.append(rocket(self.m_rocket_location_1.X, self.m_rocket_location_1.Y, self.m_rocketTexture, frame, 75, 61))
        # # self.m_rockets.append(rocket(self.m_rocket_location_2.X, self.m_rocket_location_2.Y, self.m_rocketTexture, frame + 4, 75, 61))
        # # self.m_rockets.append(rocket(self.m_rocket_location_3.X, self.m_rocket_location_3.Y, self.m_rocketTexture, frame + 8, 75, 61))
        self.m_rockets.append(rocket(0, 0, pygame.Vector2(422, 443), self.rocket_images, frame, 75, 61))
        self.m_rockets.append(
            rocket(
                0, 0, pygame.Vector2(110, 139), self.rocket_images, frame + 4, 75, 61
            )
        )
        self.m_rockets.append(
            rocket(0, 0, pygame.Vector2(510, 75), self.rocket_images, frame + 8, 75, 61)
        )
        for enemy in self.m_enemies:
            enemy.reset_enemy()
        for obj in self.master_list:
            if obj.type == "enemy":
                obj.reset_enemy()
                obj.next_level(self.m_level)


def main():
    pygame.init()
    jetpac = JetPac()
    jetpac.load_images()
    jetpac.main()


main()
