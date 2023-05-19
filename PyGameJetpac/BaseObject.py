import pygame

class BaseObject(pygame.sprite.Sprite):

    def __init__(self, x, y, position, image, frame, width, height):

        pygame.sprite.Sprite.__init__(self, self.containers)
        self.m_x = x
        self.m_y = y
        self.m_position = position
        self.m_width = width
        self.m_height = height
        self.m_frame = frame
        self.image = image
        self.m_delay_counter = 0
        self.m_elapsed_counter = 0.1

        self.rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)
        self.type = ''
        self.position = pygame.Vector2(0,0)
        self.images = []
