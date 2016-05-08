set CLIENTS;
set FEEDERS;
set LINKS within (CLIENTS union FEEDERS) cross (CLIENTS union FEEDERS);
param max_distance>0;
set L {FEEDERS,1..max_distance};
set P {FEEDERS,CLIENTS};
set NEIGHBOURS {CLIENTS union FEEDERS};
set N {FEEDERS};		#set of clients which may be allocated to feeder j
param demand {CLIENTS}>0;
param power {FEEDERS}>0;
param pow := sum{j in FEEDERS} power[j];
param hopcost {LINKS}>=0;
param T default 0;
check:
	sum {i in CLIENTS} demand[i]<= pow;

var Min>=0;
var allocated {FEEDERS,CLIENTS} binary ;	#decision variable which specifies if a client is allocated to a feeder or not
set SET_OF_O {0..T,FEEDERS} default {};		#set of clients in N[j] not forming a connected component with j
set SET_OF_CS {0..T,FEEDERS} default {};	#set of clients surrounding the connected component CC[j] not allocated to j
set SET_OF_C {0..T,FEEDERS,CLIENTS} default {};		#set of connected components in O
set SET_OF_C_FIRST_CLIENTS {0..T,FEEDERS} default {};	#clients needed to identify the different sets of connected components in C
param SET_OF_C_MIN_DISTANCE_CLIENT {0..T,FEEDERS,CLIENTS} symbolic;		#clients closest to their feeder of the connected components in C
set SET_OF_CS_RELEVANT_FOR_CC{0..T,FEEDERS,CLIENTS} default {};
set SET_OF_F {0..T,FEEDERS} default {};
set SET_OF_CS_RELEVANT_FOR_CLIENT_IN_F{0..T,FEEDERS,CLIENTS} default {};
set SET_OF_CONNECTIVITY_CUTS_FEEDERS{0..T} default {};
set SET_OF_DISTANCE_CUTS_FEEDERS{0..T} default {};

maximize Obj:
	Min;
    
subject to Margin_over_feeders{j in FEEDERS}:
    pow-sum{i in CLIENTS}allocated[j,i]*demand[i]>=Min;

subject to layer_eq{j in FEEDERS,lam in 1..(max_distance-1),i in L[j,lam+1]}:#, s in P[j,i]}:
    allocated[j,i]<=sum{k in P[j,i]}allocated[j,k];

subject to one_feeder_per_client {i in CLIENTS}:
    sum{j in FEEDERS}allocated[j,i]=1;

subject to zero_if_not_in_N {j in FEEDERS, i in (CLIENTS diff N[j])}:
	allocated[j,i]=0;
	
subject to eq224{iter in 0..T,j in SET_OF_CONNECTIVITY_CUTS_FEEDERS[iter]}:	
	sum{i in SET_OF_O[iter,j]}allocated[j,i]<=card(SET_OF_O[iter,j])*sum{k in SET_OF_CS[iter,j]}allocated[j,k];
	
subject to eq225{iter in 0..T,j in SET_OF_CONNECTIVITY_CUTS_FEEDERS[iter],v in SET_OF_C_FIRST_CLIENTS[iter,j]}:
	allocated[j,SET_OF_C_MIN_DISTANCE_CLIENT[iter,j,v]]<=sum{k in SET_OF_CS_RELEVANT_FOR_CC[iter,j,v]}allocated[j,k];
	
subject to eq226{iter in 0..T,j in SET_OF_DISTANCE_CUTS_FEEDERS[iter],i in SET_OF_F[iter,j]}:
	allocated[j,i]<=sum{k in SET_OF_CS_RELEVANT_FOR_CLIENT_IN_F[iter,j,i]}allocated[j,k];

end;