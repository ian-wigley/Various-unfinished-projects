import pygame
from base_object import BaseObject

class rocket(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, frame, width, height)
        self.rect = pygame.Rect(position.x, position.y, image.get_width(), image.get_height())

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
