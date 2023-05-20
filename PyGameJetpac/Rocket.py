import pygame
from base_object import BaseObject

class rocket(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, frame, width, height)

#         public Rocket(int x, int y, Texture2D image, int frame, int width, int height)
#         {
#             m_image = image;
#             m_frame = frame;
#             m_width = width;
#             m_height = height;
#             m_rect = new Rectangle(m_frame * m_width, 0, m_width, m_height);
#             m_screenLocation = new Vector2(x, y);
#         }

    def Update(self, x, y):
        self.m_position.x = x
        self.m_position.y = y

    def LowerSectionOne(self):
        self.m_position.x = 422
        if self.m_position.y < 383:
            self.m_position.y += 1
        return self.m_position.y >= 383

    def LowerSectionTwo(self):
        self.m_position.x = 422
        if self.m_position.y < 323:
            self.m_position.y += 1
        return self.m_position.y >= 323

    def TakeOff(self):
        self.m_position.y -= 1.5
        return self.m_position.y > -200

    def RocketRect(self):
        return pygame.Rect(self.m_position.x, self.m_position.y, self.m_width, self.m_height)
