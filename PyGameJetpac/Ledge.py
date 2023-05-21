import pygame
from base_object import BaseObject

class ledge(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, frame, width, height)
        self.rect = pygame.Rect(position.x, position.y, image.get_width(), image.get_height())

    def ledge_rect(self):
        return pygame.Rect(self.m_position.x, self.m_position.y, self.image.get_width(), self.image.get_height())
