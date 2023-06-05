import pygame
from base_object import BaseObject


class jet_man(BaseObject):
    def __init__(self, x, y, position, image):
        super().__init__(x, y, position, image, 0, 36, 52)
        self.m_width = 36
        self.m_height = 52
        self.images.append(image)
        self.images.append(pygame.transform.flip(image, True, False))
        self.rect = pygame.Rect(
            position.x, position.y, image.get_width(), image.get_height()
        )
        self.m_position = pygame.Vector2(0, 0)
        self.m_old_position = pygame.Vector2(0, 0)

    def move(self, position: pygame.Vector2, direction: str) -> None:
        if position != self.m_old_position:
            self.m_old_position = position
            self.m_position = position
            if direction == "right":
                self.image = self.images[0]
            else:
                self.image = self.images[1]

    def update(self) -> None:
        self.rect.move_ip(self.m_position.x, self.m_position.y)

    def jet_man_rect(self) -> pygame.Rect:
        return pygame.Rect(self.m_x, self.m_y, 36, 52)

    @property
    def jet_man_position(self) -> tuple[int, int]:
        return self.rect.center
