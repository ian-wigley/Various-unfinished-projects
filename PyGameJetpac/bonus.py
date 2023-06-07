import pygame
import random
from base_object import BaseObject

class bonus(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, frame, width, height)
        self.bonusLanded = False
        self.m_prevFrame = 0
        self.m_width = image.get_width() / 5
        self.m_height = image.get_height() + 2
        self.rect = pygame.Rect(position.x, position.y, image.get_width(), image.get_height())
        self.position = pygame.Vector2(random.randint(0, 750), random.randint(0, 0))

    def update(self) -> None:
        if (not self.bonusLanded):
            self.m_position.y += 1
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)

    def bonus_rectangle(self) -> pygame.Rect:
        return pygame.Rect(self.m_position.x, self.m_position.y, self.m_width, self.m_height)

    def bonus_landed(self, value) -> None:
        self.bonusLanded = value

    def reset(self) -> None:
        self.m_prevFrame = self.m_frame
        self.m_frame = random.randint(0, 4)
        if (self.m_frame == self.m_prevFrame):
            self.m_frame = (self.m_frame + 1) % 4
        self.m_position.x = random.randint(0, 750)
        self.m_position.y = -30
        self.bonusLanded = False
