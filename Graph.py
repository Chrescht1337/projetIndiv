from copy import deepcopy
from random import randint

from Client import *
from Feeder import *


class Graph:
    def __init__(self, dimI, dimJ):
        self.dimI = dimI
        self.dimJ = dimJ
        self.graph = []
        self.clients = []
        self.feeders = []
        self.minClientDemand = 3
        self.maxClientDemand = 7
        self.graphDemand = 0

    def generateClients(self):
        for i in range(self.dimI):
            row = []
            for j in range(self.dimJ):
                demand = randint(self.minClientDemand, self.maxClientDemand)
                self.graphDemand += demand
                row.append(Client(i, j, demand))
            self.clients.append(deepcopy(row))
        self.graph = deepcopy(self.clients)

    def createFeeders(self):
        pow = self.graphDemand // self.dimI + 1
        for i in range(0, self.dimI, 2):
            j = randint(1, self.dimJ - 1)
            feeder = Feeder(i, j, pow)
            self.clients[i].remove(self.clients[i][j])
            self.graph[i][j] = feeder
            self.feeders.append(deepcopy(feeder))

    def connectNeighbours(self):
        iRange = [0, 0, 1, -1]
        jRange = [1, -1, 0, 0]
        for i in range(1, self.dimI - 1):
            for j in range(1, self.dimJ - 1):
                for k in range(len(iRange)):
                    self.graph[i][j].addNeighbour(self.graph[i + iRange[k]][j + jRange[k]])

    def getClientSet(self):
        clients = 'set CLIENTS := '
        for i in range(self.dimI):
            for j in range(len(self.clients[i])):
                clients += str(self.clients[i][j]) + ' '
        clients += ";\n"
        return clients

    def getFeederSet(self):
        feeders = 'set FEEDERS := '
        for f in range(len(self.feeders)):
            feeders += self.feeders[f] + ' '
        feeders += ";\n"
        return feeders

    def __str__(self):
        return self.getClientSet()

    def writeToFile(self, filename):
        try:
            f = open(filename, 'a')
            data = ''
            data += self.getClientSet()
            data += self.getFeederSet()

            f.write(data)
            f.close()
        except IOError:
            print("Error writing graph to file")
