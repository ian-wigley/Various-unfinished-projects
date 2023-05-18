import pygame

class BaseObject:
    def __init__(self, x, y, position, image, frame, width, height):
        self.m_x = x
        self.m_y = y
        self.m_position = position
        self.m_width = width
        self.m_height = height
        self.m_frame = frame
        self.image = image
        self.m_delay_counter = 0
        self.m_elapsed_counter = 0.1
        self.m_rect = pygame.Rect(self.m_frame * self.m_width, 0, self.m_width, self.m_height)
        self.type = ''

    def update(self):
        # Overriden method
        pass

    def draw(self, screen):
        #pygame.draw.rect(screen, (250,250,250), self.rect)
        screen.blit(self.image, self.m_position, self.m_rect)
        #screen.blit(self.image, self.m_rect)

    def get_rect(self):
        return pygame.Rect(self.m_position.x, self.m_position.y, self.m_width, self.m_height)