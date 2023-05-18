import pygame
from BaseObject import BaseObject

class jetman(BaseObject):
    def __init__(self, x, y, position, image):
        super().__init__(x, y, position, image, 0, 0, 0)
        self.right_facing_image = image
        self.left_facing_image = pygame.transform.flip(image, True, False)
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)

    def update(self):
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)

    def draw(self, screen, facing = "right"):
        if facing == "right":
            screen.blit(self.right_facing_image, (self.m_x, self.m_y, 600, 800), (0,0,36,52))
        elif facing == "left":
            screen.blit(self.left_facing_image, (self.m_x, self.m_y, 600, 800), (146,0,36,52))

    def JetmanRect(self):
        return pygame.Rect(self.m_x, self.m_y, 36, 52)

    def JetmanPosition(self):
        return self.m_position
