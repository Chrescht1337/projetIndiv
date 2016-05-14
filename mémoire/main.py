from Graph import *
from sys import argv

if __name__ == "__main__":
    dataFile = "graph.dat"
    if len(argv)==3:
        g = Graph(int(argv[-2]),int(argv[-1]))
        g.setUp(dataFile)
    elif len(argv)==4:
        g = Graph(int(argv[-3]),int(argv[-2]),int(argv[-1]))
        g.setUp(dataFile)
    else:
        print("Incorrect number of parameters")

