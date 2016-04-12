set CLIENTS;
set FEEDERS;
set LINKS within (CLIENTS union FEEDERS) cross (CLIENTS union FEEDERS);
param max_distance>0;
set L {FEEDERS,1..max_distance};
set P {FEEDERS,CLIENTS};
param demand {CLIENTS}>0;
param power {FEEDERS}>0;
param pow := sum{j in FEEDERS} power[j];
check:
sum {i in CLIENTS} demand[i]<= pow;
param hopcost {LINKS}>0;

var allocated {FEEDERS,CLIENTS} binary ;
var Minimum >=0;
maximize Margin{j in FEEDERS}:
    pow-sum{i in CLIENTS}allocated[j,i]*demand[i];
subject to one_feeder_per_client {i in CLIENTS}:
    sum{j in FEEDERS}allocated[j,i]=1;
end;