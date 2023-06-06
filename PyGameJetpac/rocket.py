import pygame
from base_object import BaseObject

class rocket(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, frame, width, height)
        self.rect = pygame.Rect(position.x, position.y, image.get_width(), image.get_height())

    def lower_section_one(self) -> int:
        self.m_position.x = 422
        if self.m_position.y < 383:
            self.m_position.y += 1
        return self.m_position.y >= 383

    def lower_section_two(self) -> int:
        self.m_position.x = 422
        if self.m_position.y < 323:
            self.m_position.y += 1
        return self.m_position.y >= 323

    def take_off(self) -> int:
        self.m_position.y -= 1.5
        return self.m_position.y > -200

    def rocket_rect(self) -> pygame.Rect:
        return pygame.Rect(self.m_position.x, self.m_position.y, self.m_width, self.m_height)

    @property
    def update_position(self) -> pygame.Vector2:
        return self.m_position

    @update_position.setter
    def update_position(self, value: pygame.Vector2) -> None:
        self.m_position = value