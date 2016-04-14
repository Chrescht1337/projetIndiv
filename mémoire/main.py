from Graph import *
from sys import argv

if __name__ == "__main__":
    dataFile = "graph.dat"
    l=argv
    #g = Graph(int(l[-2]),int(l[-1]))
    g = Graph(4,4)
    g.generateClients()
    g.createFeeders()
    g.connectNeighbours()
    g.createAdjMat()
    g.Floyd()
    g.createLayers()
    g.createR()
    g.createP()
    g.writeToFile(dataFile)
