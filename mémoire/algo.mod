model modelBasic.mod;
data graph.dat
#drop eq24;
#drop eq25;
#drop eq26;

#================
#Building sets for connectivity cuts
#================
param DIST_TO_FEEDER {FEEDERS,CLIENTS} ;
param cc_members;
set FEASIBLE default {};
set TREATED  default {};
#set NOT_TREATED default {};
#let FEASIBLE := {1}; #used as boolean value
param t;
let t:=1;
repeat {
#for {t in 1..10}{
	solve;
	#drop eq24;
	#drop eq25;
	#drop eq26;
	display t;
	let FEASIBLE := {} ;
	let DISTANCE_CUTS_FEEDERS := {};
	let CONNECTIVITY_CUTS_FEEDERS := {};
	for {j in FEEDERS}{
		let N[j]:= {};
		let CC[j]:={};
		let CS[j]:= {};
		let C_FIRST_CLIENTS[j] := {};
		let F[j]:= {};
		for { i in CLIENTS}{
			let C[j,i]:={};
			#let C_MIN_DISTANCE_CLIENT[j,i]:={};
			let CS_RELEVANT_FOR_CC[j,i]:={};
			let CS_RELEVANT_FOR_CLIENT_IN_F[j,i]:={};
			if allocated[j,i] then{
				let N[j]:=N[j] union {i};
			}
		}
	}
	display N;
	for {j in FEEDERS}{
		for {n in NEIGHBOURS[j]}{
		#first stage of breadth-first exploration to determine
		#distances of connected clients to feeder j.
			if n in N[j] then{
				let CC[j] := CC[j] union {n};	
				let DIST_TO_FEEDER[j,n]:= 1;			
			}
		}
		let cc_members := 0;
		repeat while cc_members<card(CC[j]){
			let cc_members:=card(CC[j]);
			for {v in CC[j],n in NEIGHBOURS[v]}{   #clients connected to feeder j are added one by one to CC
				#for {n in NEIGHBOURS[v]}{
					if n in N[j] then{
						if n not in CC[j] then{
							let CC[j]:=CC[j] union {n};
							let DIST_TO_FEEDER[j,n]:=DIST_TO_FEEDER[j,v] + 1;	
						}
					}
					else if n in CLIENTS then{  #feeders are excluded from the cut set
						let CS[j]:=CS[j] union {n};
					}
				#}
			}
		};
		let O[j] := N[j] diff CC[j];
		
		#true if set of customers allocated to feeder j is not connected
		if card(O[j])>0 then {
			#restore eq24;   #adding connectivity cuts to the master problem
			#restore eq25;
			display O[j];
			display CC[j];
			display CS[j];
			display j;
			let CONNECTIVITY_CUTS_FEEDERS := CONNECTIVITY_CUTS_FEEDERS union {j};
			let FEASIBLE := FEASIBLE union {0}; #master problem has to be solved again

			let TREATED := {};
			for {v in O[j]}{
				if v not in TREATED then {
					let C_FIRST_CLIENTS[j]:=C_FIRST_CLIENTS[j] union {v};
					let C[j,v] := C[j,v] union {v};
					for {k in C[j,v]}{
						for {n in NEIGHBOURS[k]}{
							if n in O[j] and n not in C[j,v]then {
								let C[j,v]:=C[j,v] union {n};
								let TREATED := TREATED union {n};
							}
						}
					}	
				}
			}

			#preparing CS for eq25
			for {v in C_FIRST_CLIENTS[j] }{
				let C_MIN_DISTANCE_CLIENT[j,v] := v;
			}
			#display C_MIN_DISTANCE_CLIENT;
			#choosing closest client to feeder for every connected component in O[j]
			for {v in C_FIRST_CLIENTS[j],c in C[j,v]}{#,i_cc in C_MIN_DISTANCE_CLIENT[j,v] }{
				if hopcost[j,c] < hopcost[ j , C_MIN_DISTANCE_CLIENT[j,v] ] then {
					#let C_MIN_DISTANCE_CLIENT[j,v] := C_MIN_DISTANCE_CLIENT[j,v] diff C_MIN_DISTANCE_CLIENT[j,v];
					let C_MIN_DISTANCE_CLIENT[j,v]:=c; #C_MIN_DISTANCE_CLIENT[j,v] union {c};
				}
			}
			for {v in C_FIRST_CLIENTS[j], k in CS[j]}{#, i_cc in C_MIN_DISTANCE_CLIENT[j,v], k in CS[j]}{
				if (hopcost[j,k]+ hopcost[C_MIN_DISTANCE_CLIENT[j,v],k])<= max_distance then
					let CS_RELEVANT_FOR_CC[j,v] := CS_RELEVANT_FOR_CC[j,v] union {k};
			}
		}
		
		
		#true if set of customers allocated to feeder j is connected
		#if card(O[j])=0 then {
		#	#display j;
		#	#preparing set F
		#	for {i in CC[j]}{
		#		if DIST_TO_FEEDER[j,i] = max_distance+1 then {
		#			let F[j] := F[j] union {i};
		#		}
		#	}
		#	#display F[j];
		#	
		#	if card(F[j]) > 0 then {
		#		#restore eq26;
		#		let DISTANCE_CUTS_FEEDERS := DISTANCE_CUTS_FEEDERS union {j};
		#		#display DISTANCE_CUTS_FEEDERS;
		#		let FEASIBLE := FEASIBLE union {0};
		#		for {i in F[j],k in CS[j]}{
		#			if hopcost[j,k]+hopcost[k,i]<=max_distance then{
		#				let CS_RELEVANT_FOR_CLIENT_IN_F[j,i]:=CS_RELEVANT_FOR_CLIENT_IN_F[j,i] union {k};
		#			}
		#			#display CS_RELEVANT_FOR_CLIENT_IN_F[j,i];
		#		}
		#		
		#	}
		#	
		#}
	}
	let t:=t+1;
	#display DIST_TO_FEEDER;
	#display DISTANCE_CUTS_FEEDERS;
	#display F;
	#for {j in FEEDERS,i in CLIENTS} let allocated[j,i]:=0;
}until card(FEASIBLE) =0 or t = 10;
#};
