import pygame
from base_object import BaseObject

class bullet(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height, left):
        super().__init__(x, y, position, image, frame, width, height)
        self.m_left = left
        self.m_offscreen = False

    def update(self):
        if (self.m_position.x < 800 and not self.m_left):
            self.m_position.x += 3
        elif (self.m_position.x > -40):
            self.m_position.x -= 3
        if (self.m_position.x >= 800 or self.m_position.x <= -40):
            self.m_offscreen = True
        self.rect = pygame.Rect(self.m_position.x, self.m_position.y, self.image.get_width(), self.image.get_height())

    def offscreen(self):
        return self.m_offscreen

