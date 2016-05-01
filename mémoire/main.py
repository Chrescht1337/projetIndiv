from Graph import *
from sys import argv

if __name__ == "__main__":
    dataFile = "graph.dat"
    l=argv
    g = Graph(int(l[-2]),int(l[-1]))
    g.setUp(dataFile)

