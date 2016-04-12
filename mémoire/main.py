from Graph import *

if __name__ == "__main__":
    dataFile = "graph.dat"
    g = Graph(5, 5)
    g.generateClients()
    g.createFeeders()
    g.connectNeighbours()
    g.createAdjMat()
    g.Floyd()
    g.createLayers()
    g.createR()
    g.createP()
    g.writeToFile(dataFile)
