import pygame
import random
from BaseObject import BaseObject

class fuel(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, frame, width, height)
        self.landed_on_ledge = False
        self.m_width = image.get_width()
        self.m_height = image.get_height() + 2
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)
        self.m_position = pygame.Vector2(random.randint(0, 750), random.randint(0, 0))

    def Update(self, ledges):
        if (not self.landed_on_ledge):
            for ledge in ledges:
                if (not self.FuelRect().colliderect(ledge.LedgeRect())):
                    self.m_position.y += 0.2
                else:
                    self.landed_on_ledge = True

    def UpdatePosition(self, x, y):
        self.m_position.x = x
        self.m_position.y = y

    def LowerFuel(self):
        self.m_position.x = 440
        if (self.m_position.y < 450):
            self.m_position.y += 1
        return self.m_position.y > 448

    def FuelRect(self):
        return pygame.Rect(self.m_position.x, self.m_position.y, self.m_width, self.m_height)
