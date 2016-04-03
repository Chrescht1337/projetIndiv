from Vertex import *


class Client(Vertex):
    def __init__(self, i, j, demand):
        super.__init__(self, i, j)
        self.name = 'X' + "_" + str(i) + '_' + str(j)
        self.demand = demand

    def getDemand(self):
        return self.demand
