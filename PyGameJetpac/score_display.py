import pygame

class ScoreDisplay(pygame.sprite.Sprite):

    def __init__(self):
        pygame.sprite.Sprite.__init__(self)
        self.font = pygame.Font(None, 20)
        self.font.set_italic(1)
        self.color = "white"
        self.lastscore = -1
        self.score = 0
        self.update()
        self.rect = self.image.get_rect().move(10, 10)

    def update(self)-> None:
        if self.score != self.lastscore:
            self.lastscore = self.score
            msg = "Score : %d" % self.score
            self.image = self.font.render(msg, 0, self.color)

    @property
    def update_score(self):
        return self.score

    @update_score.setter
    def update_score(self, value:int):
        self.score = value
