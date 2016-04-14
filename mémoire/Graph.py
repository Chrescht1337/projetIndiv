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
        self.clients = dict()
        self.feeders = dict()
        self.vertices=dict()
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
                c=Client(i, j, demand)
                row.append(c.getName())
                self.clients[c.getName()]=c
            self.graph.append(deepcopy(row))

    def createFeeders(self):
        pow = self.graphDemand  # // self.dimI + 1
        for i in range(0, self.dimI, 2):
            j = randint(1, self.dimJ - 1)
            feeder = Feeder(i, j, pow)
            self.clients.pop(self.graph[i][j])
            self.graph[i][j] = feeder.getName()
            self.feeders[feeder.getName()]=feeder
        self.vertices = dict(self.clients,**self.feeders)

    def connectNeighbours(self):
        iRange = [0, 0, 1, -1]
        jRange = [1, -1, 0, 0]
        for i in range(1, self.dimI - 1):
            for j in range(1, self.dimJ - 1):
                for k in range(len(iRange)):
                    v=self.graph[i][j]
                    n=self.graph[i + iRange[k]][j + jRange[k]]
                    self.connectVertices(v,n)

        for j in range(len(self.graph[0]) - 1):
            # for the first line
            v1=self.graph[0][j]
            n1=self.graph[0][j+1]
            self.connectVertices(v1,n1)
            # for the last line
            v2=self.graph[-1][j]
            n2=self.graph[-1][j + 1]
            self.connectVertices(v2,n2)


        for i in range(len(self.graph) - 1):
            # for the first column
            v1=self.graph[i][0]
            n1=self.graph[i+1][0]
            self.connectVertices(v1,n1)
            # for the last column
            v2=self.graph[i][-1]
            n2=self.graph[i + 1][-1]
            self.connectVertices(v2,n2)

    def connectVertices(self,v,n):
        self.vertices[v].addNeighbour(self.vertices[n])
        self.vertices[n].addNeighbour(self.vertices[v])

    def createAdjMat(self):
        for v in self.vertices:
            self.adjacencyMatrix[v] = dict()
            self.adjacencyMatrix[v][v] = 0
            neighbours=self.vertices[v].getNeighbours()
            for n, dist in neighbours.items():
                self.adjacencyMatrix[v][n.getName()] = dist

    def Floyd(self):
        infinity = float("inf")
        for k in self.vertices:
            for x in self.vertices:
                if self.adjacencyMatrix[x].get(k, infinity) < infinity:
                    for y in self.vertices:
                        if self.adjacencyMatrix[k].get(y,infinity) < infinity:
                            if self.adjacencyMatrix[x][k] + self.adjacencyMatrix[k][y] < self.adjacencyMatrix[x].get(y,infinity):
                                self.adjacencyMatrix[x][y] = self.adjacencyMatrix[x][k] + self.adjacencyMatrix[k][y]

    def createLayers(self):
        for j in self.feeders:
            self.layers[j]=[]
            for lam in range(self.maxDistance+1):
                self.layers[j].append([])

            for i in self.clients:
                try:
                    self.layers[j][self.adjacencyMatrix[j][i]].append(i)
                except IndexError:
                    pass



    def createR(self):
        for j in self.feeders:
            self.setR[j]=dict()
            for lam in range(1,self.maxDistance):
                for k in self.layers[j][lam]:
                    self.setR[j][k]=[]
                    for v in self.clients:
                        if self.adjacencyMatrix[j][v]>lam and self.adjacencyMatrix[v][k]<=self.maxDistance-lam:
                            self.setR[j][k].append(v)

    def createP(self):
        for j in self.feeders:
            self.setP[j]=dict()
            for lam in range(1,self.maxDistance):
                for i in self.layers[j][lam+1]:
                    self.setP[j][i]=[]
                    for k in self.layers[j][lam]:
                        if i in self.setR[j][k]:
                            self.setP[j][i].append(k)


    def getClientSet(self):
        text = 'set CLIENTS := '
        for c in self.clients:
                text += c + ' '
        text += ";\n"
        return text

    def getFeederSet(self):
        text = 'set FEEDERS := '
        for f in self.feeders:
            text += f + ' '
        text += ";\n"
        return text

    def getHopCounts(self):
        text = 'param: LINKS: hopcost:=\n'
        for v1 in self.vertices:
            for v2 in self.vertices:
                if v1 != v2:
                    text+= v1 + ' ' + v2 + ' ' + str(self.adjacencyMatrix[v1][v2])+ ','
            text+='\n'
        text = text[:-2] + ';\n'
        return text

    def getSetPData(self):
        text=''
        for j in self.setP:
            for i in self.setP[j]:
                text+='set P[{0},{1}]:='.format(j,i)
                for client in self.setP[j][i]:
                    text+=' '+client+' '
                text+=';\n'

        for j in self.setP:
            for i in self.clients:
                if i not in self.setP[j]:
                    text+='set P[{0},{1}] '.format(j,i)
                    text+=";\n"

        return text

    def getLayersData(self):
        text=''
        for j in self.layers:
            for lam in range(1,self.maxDistance):
                if self.layers[j][lam]!=[]:
                    text+='set L[{0},{1}]:='.format(j,lam)
                    for i in self.layers[j][lam]:
                        text+=' '+i+' '
                    text+=";\n"
        return text


    def getClientDemand(self):
        text = 'param demand :=\n'
        for c in self.clients:
            text += "{0} {1}\n".format(c,self.clients[c].getDemand())
        text += ';\n'
        return text

    def getFeederPower(self):
        text = 'param power :='
        for f in self.feeders:
            text += "{0} {1},".format(f,self.feeders[f].getPower())
        text=text[:-1]
        text += ';\n'
        return text

    def getMaxDistance(self):
        text = 'param max_distance :=' + str(self.maxDistance) + ';\n'
        return text

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
            data += self.getSetPData()
            data+= self.getLayersData()
            f = open(filename, 'w')
            f.write(data)
            f.write("end;")
            f.close()
        except IOError:
            print("Error writing graph to file")
