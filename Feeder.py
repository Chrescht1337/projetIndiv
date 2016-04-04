from Vertex import *


class Feeder(Vertex):
    def __init__(self, i, j, power):
        super(Feeder, self).__init__(i, j)
        self.pow = power
        self.name = 'F' + "_" + str(i) + '_' + str(j)

    def getPower(self):
        return self.pow
