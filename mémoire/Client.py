from Vertex import *


class Client(Vertex):
    def __init__(self, i, j, demand):
        super(Client, self).__init__(i, j)
        self.name = 'C' + "_" + str(i) + '_' + str(j)
        self.demand = demand

    def getDemand(self):
        return self.demand
