class Vertex:
    def __init__(self, i, j):
        self.i = i
        self.j = j
        self.neighbours = []
        self.name = ''

    def addNeighbour(self, v):
        if [v, 1] not in self.neighbours:
            self.neighbours.append([v, 1])

    def getNeighbours(self):
        return self.neighbours

    def __str__(self):
        return self.name
