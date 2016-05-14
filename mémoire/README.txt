Pour lancer le scripte de python qui génère les graphes, tappez :

python3 main.py [dimX] [dimY] [step]

dimX et dimY étant évidemment les dimensions du graphe.
step indique la fréquence des fournisseurs. c'est optionnel de l'indiquer, la valeur par défaut est 2, ce qui insère un fournisseur tous les 2 lignes dans le graphe.
Lorsque le graphe créé peut être résolu, le scripte affiche "success". S'il affiche "failed" les contraintes de distances ne peuvent pas être respectées, vous devez donc relancer le script.

Le script sauvegarde les données du graphe dans un fichier nommé 'graph.dat'.

dans la console AMPL, tappez:

options solver cplex;
commands cuttinPlane.mod;

et le l'algorithme sera lancé.
