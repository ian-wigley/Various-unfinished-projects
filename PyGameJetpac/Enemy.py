import pygame
import random
from BaseObject import BaseObject

class enemy(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, 0, 0, 0) # frame, width, height)
        self.m_width = image.get_width() / 8
        self.m_height = image.get_height()
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)
        self.m_position = pygame.Vector2(random.randint(0, 800), random.randint(50, 440))
        self.type = 'enemy'

    def update(self):
        if self.m_position.x > -70:
            self.m_position.x -= 1
            #self.m_rect.x -= 1
        else:
            self.reset_enemy()

    def next_level(self, level):
        self.m_frame = level % 8
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)

    def reset_enemy(self):
        self.m_position = pygame.Vector2(random.randint(800, 1200), random.randint(50, 440))
