import pygame
import random
from BaseObject import BaseObject

class bonus(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, frame, width, height)
        self.bonusLanded = False
        self.m_prevFrame = 0
        self.m_width = image.get_width() / 5
        self.m_height = image.get_height() + 2
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)
        self.m_position = pygame.Vector2(random.randint(0, 750), random.randint(0, 0))

    def Update(self):
        if (not self.bonusLanded):
            self.m_position.y += 1
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)

    def BonRect(self):
        return pygame.Rect(self.m_position.x, self.m_position.y, self.m_width, self.m_height)

    def bonus_landed(self, value):
        self.bonusLanded = value

    def Reset(self):
        self.m_prevFrame = self.m_frame
        self.m_frame = random.randint(0, 4)
        if (self.m_frame == self.m_prevFrame):
            self.m_frame = (self.m_frame + 1) % 4
        self.m_position.x = random.randint(0, 750)
        self.m_position.y = -30
        self.bonusLanded = False
