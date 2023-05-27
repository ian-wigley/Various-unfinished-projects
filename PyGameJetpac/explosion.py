import pygame
from base_object import BaseObject

class explosion(BaseObject):
    def __init__(self, x, y, position, image, frame, width, height):
        super().__init__(x, y, position, image, frame, width, height)
        self.m_animationComplete = False
        self.m_height = image.get_height()
        self.m_width = image.get_width() / 16

    def update(self)-> None:
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)
        self.m_delay_counter += self.m_elapsed_counter
        if (self.m_delay_counter > 2.2):
            self.m_delay_counter = 0
            if (self.m_frame < 16):
                self.m_frame += 1
            else:
                self.m_animationComplete = True

    def animation_complete(self):
        return self.m_animationComplete
