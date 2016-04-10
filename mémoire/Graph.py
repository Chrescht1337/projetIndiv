from copy import deepcopy
from random import randint
from Client import *
from Feeder import *


class Graph:
    def __init__(self, dimI, dimJ):
        self.dimI = dimI
        self.dimJ = dimJ
        self.graph = []
        self.adjacencyMatrix = dict()
        self.clients = []
        self.feeders = []
        self.layers= dict()
        self.setR= dict()
        self.setP= dict()
        self.minClientDemand = 3
        self.maxClientDemand = 7
        self.graphDemand = 0
        self.maxDistance = dimI

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
        pow = self.graphDemand  # // self.dimI + 1
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
                    self.graph[i + iRange[k]][j + jRange[k]].addNeighbour(self.graph[i][j])

        for j in range(len(self.graph[0]) - 1):
            # for the first line
            self.graph[0][j].addNeighbour(self.graph[0][j + 1])
            self.graph[0][j + 1].addNeighbour(self.graph[0][j])
            # for the last line
            self.graph[-1][j].addNeighbour(self.graph[-1][j + 1])
            self.graph[-1][j + 1].addNeighbour(self.graph[-1][j])

        for i in range(len(self.graph) - 1):
            # for the first column
            self.graph[i][0].addNeighbour(self.graph[i + 1][0])
            self.graph[i + 1][0].addNeighbour(self.graph[i][0])
            # for the last column
            self.graph[i][-1].addNeighbour(self.graph[i + 1][-1])
            self.graph[i + 1][-1].addNeighbour(self.graph[i][-1])

    def createAdjMat(self):
        for i in range(len(self.graph)):
            for j in range(len(self.graph[i])):
                currentV = self.graph[i][j]
                self.adjacencyMatrix[currentV] = dict()
                self.adjacencyMatrix[currentV][currentV] = 0
                neighbours = currentV.getNeighbours()
                for v, dist in neighbours.items():
                    self.adjacencyMatrix[currentV][v] = dist

    def Floyd(self):
        infinity = float("inf")
        for k in range(len(self.graph)):
            for kk in range(len(self.graph[k])):
                kVertex = self.graph[k][kk]
                for x in range(len(self.graph)):
                    for xx in range(len(self.graph[x])):
                        xVertex = self.graph[x][xx]
                        if self.adjacencyMatrix[xVertex].get(kVertex, infinity) < infinity:
                            for y in range(len(self.graph)):
                                for yy in range(len(self.graph[y])):
                                    yVertex = self.graph[y][yy]
                                    if self.adjacencyMatrix[kVertex].get(yVertex,
                                                                         infinity) < infinity:
                                        if self.adjacencyMatrix[xVertex][kVertex] + \
                                                self.adjacencyMatrix[kVertex][yVertex] < \
                                                self.adjacencyMatrix[xVertex].get(yVertex,
                                                                                  infinity):
                                            self.adjacencyMatrix[xVertex][yVertex] = \
                                                self.adjacencyMatrix[xVertex][kVertex] + \
                                                self.adjacencyMatrix[kVertex][yVertex]

    def createLayers(self):
        for j in self.feeders:
            self.layers[j]=dict()
            for i in range(len(self.clients)):
                for client in self.clients[i]:
                    self.layers[j][client] =0

    def createR(self):
        pass

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
            feeders += str(self.feeders[f]) + ' '
        feeders += ";\n"
        return feeders

    def getHopCounts(self):
        text = 'param: LINKS: hopcost:=\n'
        for i in range(len(self.graph)):
            for j in range(len(self.graph[i])):
                v1 = self.graph[i][j]
                for k in range(len(self.graph)):
                    for m in range(len(self.graph[k])):
                        v2 = self.graph[k][m]
                        if v1 != v2:
                            text+= str(v1) + ' ' + str(v2) + ' ' + str(self.adjacencyMatrix[v1][v2])+ ','
                            text += '\n'
        text = text[:-2] + ';\n'
        return text




        #
        # for row in self.graph:
        #     for v in row:
        #         neighbours = v.getHopCounts()
        #         for (n, hops) in neighbours.items():
        #             text += str(v) + ' ' + str(n) + ' ' + str(hops) + ', '
        #         text += '\n'
        # text = text[:-3] + ';\n'
        # return text

    def getClientDemand(self):
        t = 'param demand :=\n'
        for row in self.clients:
            for c in row:
                t += str(c) + ' ' + str(c.getDemand()) + '\n'
        t += ';\n'
        return t

    def getFeederPower(self):
        t = 'param power :='
        for f in self.feeders[:-1]:
            t += str(f) + ' ' + str(f.getPower()) + ', '
        t += str(self.feeders[-1]) + ' ' + str(self.feeders[-1].getPower()) + ';\n'
        return t

    def getMaxDistance(self):
        t = 'param max_distance :=' + str(self.maxDistance) + ';\n'
        return t

    def __str__(self):
        return self.getClientSet()

    def writeToFile(self, filename):
        try:
            data = ''
            data += self.getClientSet()
            data += self.getFeederSet()
            data += self.getClientDemand()
            data += self.getFeederPower()
            data += self.getHopCounts()
            data += self.getMaxDistance()

            f = open(filename, 'w')
            f.write(data)
            f.close()
        except IOError:
            print("Error writing graph to file")
