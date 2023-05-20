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

    def move(self, position):
        self.position = position

    def update(self):
        self.rect.move_ip(self.position.x, self.position.y)

    # def draw(self, screen, facing = "right"):
    #     if facing == "right":
    #         screen.blit(self.right_facing_image, (self.m_x, self.m_y, 600, 800), (0,0,36,52))
    #     elif facing == "left":
    #         screen.blit(self.left_facing_image, (self.m_x, self.m_y, 600, 800), (146,0,36,52))

    def JetmanRect(self):
        return pygame.Rect(self.m_x, self.m_y, 36, 52)

    def JetmanPosition(self):
        return self.m_position
