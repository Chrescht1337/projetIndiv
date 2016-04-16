set CLIENTS;
set FEEDERS;
set LINKS within (CLIENTS union FEEDERS) cross (CLIENTS union FEEDERS);
param max_distance>0;
set L {FEEDERS,1..max_distance};
set P {FEEDERS,CLIENTS};
set NEIGHBOURS {CLIENTS union FEEDERS};
param demand {CLIENTS}>0;
param power {FEEDERS}>0;
param pow := sum{j in FEEDERS} power[j];
check:
sum {i in CLIENTS} demand[i]<= pow;
param hopcost {LINKS}>0;
var Min>=0;
var allocated {FEEDERS,CLIENTS} binary ;
set N {FEEDERS} default {};
set CC {FEEDERS} default {};
set O {FEEDERS} default {};
set CS {FEEDERS} default {};
set C {FEEDERS,CLIENTS} default {};
set C_FIRST_CLIENTS {FEEDERS} default {};
set C_MIN_DISTANCE_CLIENT {FEEDERS,CLIENTS} default {};
#maximize Min;
maximize Obj:
	Min;
    #pow-sum{i in CLIENTS}allocated[j,i]*demand[i];
subject to Margin_over_feeders{j in FEEDERS}:
    pow-sum{i in CLIENTS}allocated[j,i]*demand[i]>=Min;

subject to layer_eq{j in FEEDERS,lam in 1..(max_distance-1),i in L[j,lam], s in P[j,i]}:
    allocated[j,i]<=sum{k in P[j,i]}allocated[j,k];

subject to one_feeder_per_client {i in CLIENTS}:
    sum{j in FEEDERS}allocated[j,i]=1;

subject to demand_for_power_sufficiency {j in FEEDERS}:
	power[j]-sum{i in CLIENTS}allocated[j,i]*demand[i]>=0;
	
subject to eq24{j in FEEDERS}:
	sum{i in O[j]}allocated[j,i]<=card(O[j])*sum{k in CS[j]}allocated[j,k];

end;