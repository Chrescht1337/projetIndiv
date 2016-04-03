from Vertex import *


class Feeder(Vertex):
    def __init__(self, i, j, power):
        super.__init__(self, i, j)
        self.pow = power
        self.name = 'O' + "_" + str(i) + str(j)
