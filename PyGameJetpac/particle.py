import pygame
import random
from base_object import BaseObject

class particle(BaseObject):
    def __init__(self, x=0, y=0, position=pygame.Vector2(), image=0, frame=0, width=0, height=0):
        super().__init__(x, y, position, image, frame, width, height)
        self.m_position = pygame.Vector2(random.randint(0, 800), random.randint(50, 440))
        self.m_rect = image.get_rect()
        self.lifeSpan = 20
        self.particleX = 0
        self.particleY = 0
        self.length = 0
        self.count = 0
        self.scale = 1.0
#         self.Color[] colors = {Color.White,
#                           Color.Yellow,
#                           Color.Orange,
#                           Color.Brown,
#                           Color.Red,
#                           Color.Brown,
#                           Color.Brown,
#                           Color.Black };


    def update(self)-> None:
        self.particleY += 1
#         public void Update(int x, int y, bool facingLeft, bool showParticles)
#         {
#             if (showParticles == true)
#             {
#                 if (particleY < length)
#                 {
#                     particleY++;
#                 }
#                 if (particleY >= length)
#                 {
#                     if (facingLeft == true)
#                     {
#                         particleX = x + 20 + rand.Next(0, 10);
#                         length = y + 40 + lifeSpan;
#                         particleY = y + 40 + rand.Next(0, 10);
#                     }
#                     else
#                     {
#                         particleX = x + rand.Next(0, 10);
#                         length = y + 40 + lifeSpan;
#                         particleY = y + 40 + rand.Next(0, 10);
#                     }
#                 }

#                 if (particleY == (length - 20))
#                 {
#                     count = 0;
#                     scale = 1.0f;
#                 }
#                 if (particleY == (length - 15))
#                 {
#                     count = 1;
#                     scale = 0.9f;
#                 }
#                 if (particleY == (length - 10))
#                 {
#                     count = 2;
#                     scale = 0.8f;
#                 }
#                 if (particleY == (length - 5))
#                 {
#                     count = 3;
#                     scale = 0.7f;
#                 }
#                 if (particleY == (length))
#                 {
#                     count = 4;
#                     scale = 0.45f;
#                 }
#             }

#             // Hide the particles when not in use
#             if (showParticles == false)
#             {
#                 count = 7;
#                 particleX = 0;
#                 particleY = 0;
#                 length = 0;
#             }
#         }

#         new public void Draw(SpriteBatch spriteBatch)
#         {
#             spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.Additive);
#             Vector2 particleLocation = new Vector2(particleX, particleY);
#             spriteBatch.Draw(m_image, particleLocation, null, colors[count], 0, new Vector2(0, 9), scale, SpriteEffects.None, 0);
#             spriteBatch.End();
#         }
#     }
# }