from enum import Enum

class GameState(Enum):
    GAME_START = 'gameStart'
    GAME_ON = 'gameOn'
    GAME_OVER = 'gameOver'
    TAKE_OFF = 'takeOff'
    NEXT_LEVEL = 'nextLevel'
