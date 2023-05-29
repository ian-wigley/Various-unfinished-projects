import pygame
from base_object import BaseObject


class jetman(BaseObject):
    def __init__(self, x, y, position, image):
        super().__init__(x, y, position, image, 0, 36, 52)
        self.m_width = 36
        self.m_height = 52
        self.images = image
        self.right_facing_image = image
        self.left_facing_image = pygame.transform.flip(image, True, False)
        self.rect = pygame.Rect(
            position.x, position.y, image.get_width(), image.get_height()
        )
        self.m_position = pygame.Vector2(0, 0)

    def move(self, position) -> None:
        self.m_position = position
        self.m_x += position.x
        self.m_y += position.y

    def update(self) -> None:
        self.rect.move_ip(self.m_position.x, self.m_position.y)
        # def draw(self, screen, facing = "right"):
        #     if facing == "right":
        #         screen.blit(self.right_facing_image, (self.m_x, self.m_y, 600, 800), (0,0,36,52))
        #     elif facing == "left":
        #         screen.blit(self.left_facing_image, (self.m_x, self.m_y, 600, 800), (146,0,36,52))

    def jetman_rect(self):
        return pygame.Rect(self.m_x, self.m_y, 36, 52)

    @property
    def jetman_position(self) -> tuple[int, int]:
        return self.rect.center
