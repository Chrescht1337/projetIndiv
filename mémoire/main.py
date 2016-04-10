from Graph import *

if __name__ == "__main__":
    dataFile = "graph.dat"
    g = Graph(10, 10)
    g.generateClients()
    g.createFeeders()
    g.connectNeighbours()
    g.createAdjMat()
    g.Floyd()
    g.writeToFile(dataFile)
