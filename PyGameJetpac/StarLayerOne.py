import pygame
import random
from BaseObject import BaseObject

class starlayerone(BaseObject):
    def __init__(self, x=0, y=0, position=pygame.Vector2(), image=0, frame=0, width=0, height=0):
        super().__init__(x, y, position, image, frame, width, height)
        self.m_position = pygame.Vector2(random.randint(0, 800), random.randint(50, 440))
        #self.m_star_layer1 = pygame.Vector2(random.randint(0, 800), random.randint(50, 440))
        #self.m_star_layer2 = pygame.Vector2(random.randint(0, 800), random.randint(52, 440))
        self.m_rect = image.get_rect()

    def update(self):
        if self.m_position.x < 800:
            self.m_position.x += 2
        else:
            self.m_position.x = random.randint(-400, 0)

        # if self.m_star_layer1.x < 800:
        #     self.m_star_layer1.x += 1
        # else:
        #     self.m_star_layer1.x = random.randint(-400, 0)
        #     self.m_star_layer1.y = random.randint(50, 440)

        # if self.m_star_layer2.x < 800:
        #     self.m_star_layer2.x += 2
        # else:
        #     self.m_star_layer2.x = random.randint(-400, 0)
        #     self.m_star_layer2.y = random.randint(50, 440)

    def draw(self, screen):
        pygame.draw.circle(screen, pygame.Color(89,89,89), self.m_position, 1)
        #pygame.draw.circle(screen, pygame.Color(128,128,128), self.m_star_layer2, 1)
