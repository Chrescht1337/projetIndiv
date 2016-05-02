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
set ALLOC {FEEDERS} default {};
#param C_MIN_DISTANCE_CLIENT {FEEDERS,CLIENTS} symbolic;		#clients closest to their feeder of the connected components in C
#set CS_RELEVANT_FOR_CC{FEEDERS,CLIENTS} default {};
#set F {FEEDERS} default {};
#set CS_RELEVANT_FOR_CLIENT_IN_F{FEEDERS,CLIENTS} default {};
#set CONNECTIVITY_CUTS_FEEDERS default {};
#set DISTANCE_CUTS_FEEDERS default {};
set CC {FEEDERS} default {};	#set of clients in N[j] forming a connected component with j

repeat {
#for {t in 1..10}{
	solve;
	#drop eq24;
	#drop eq25;
	#drop eq26;
	let T:=T+1;
	display T;
	
	#display Obj;
	let FEASIBLE := {} ;
	let SET_OF_DISTANCE_CUTS_FEEDERS[T] := {};
	let SET_OF_CONNECTIVITY_CUTS_FEEDERS[T] := {};
	for {j in FEEDERS}{
		let ALLOC[j]:= {};
		let CC[j]:={};
		let SET_OF_CS[T,j]:= {};
		let SET_OF_C_FIRST_CLIENTS[T,j] := {};
		let SET_OF_F[T,j]:= {};
		for { i in CLIENTS}{
			let SET_OF_C[T,j,i]:={};
			#let C_MIN_DISTANCE_CLIENT[j,i]:={};
			let SET_OF_CS_RELEVANT_FOR_CC[T,j,i]:={};
			let SET_OF_CS_RELEVANT_FOR_CLIENT_IN_F[T,j,i]:={};
			if allocated[j,i] then{
				let ALLOC[j]:=ALLOC[j] union {i};
			}
		}
	}
	#display ALLOC;
	for {j in FEEDERS}{
		for {n in NEIGHBOURS[j]}{
		#first stage of breadth-first exploration to determine
		#distances of connected clients to feeder j.
			if n in ALLOC[j] then{
				let CC[j] := CC[j] union {n};	
				let DIST_TO_FEEDER[j,n]:= 1;			
			}
		}
		let cc_members := 0;
		repeat while cc_members<card(CC[j]){
			let cc_members:=card(CC[j]);
			for {v in CC[j],n in NEIGHBOURS[v]}{   #clients connected to feeder j are added one by one to CC
				#for {n in NEIGHBOURS[v]}{
					if n in ALLOC[j] then{
						if n not in CC[j] then{
							let CC[j]:=CC[j] union {n};
							let DIST_TO_FEEDER[j,n]:=DIST_TO_FEEDER[j,v] + 1;	
						}
					}
					else if n in CLIENTS then{  #feeders are excluded from the cut set
						let SET_OF_CS[T,j]:=SET_OF_CS[T,j] union {n};
					}
				#}
			}
		};
		let SET_OF_O[T,j] := ALLOC[j] diff CC[j];
		
		#true if set of customers allocated to feeder j is not connected
		if card(SET_OF_O[T,j])>0 then {
			#restore eq24;   #adding connectivity cuts to the master problem
			#restore eq25;
			#display O[j];
			#display CC[j];
			#display CS[j];
			#display j;
			let SET_OF_CONNECTIVITY_CUTS_FEEDERS[T] := SET_OF_CONNECTIVITY_CUTS_FEEDERS[T] union {j};
			let FEASIBLE := FEASIBLE union {0}; #master problem has to be solved again

			let TREATED := {};
			for {v in SET_OF_O[T,j]}{
				if v not in TREATED then {
					let SET_OF_C_FIRST_CLIENTS[T,j]:=SET_OF_C_FIRST_CLIENTS[T,j] union {v};
					let SET_OF_C[T,j,v] := SET_OF_C[T,j,v] union {v};
					let cc_members := 0;
					repeat while cc_members<card(SET_OF_C[T,j,v]){
						let cc_members := card(SET_OF_C[T,j,v]);
						for {k in SET_OF_C[T,j,v],n in NEIGHBOURS[k]}{
							if n in SET_OF_O[T,j] and n not in SET_OF_C[T,j,v]then {
								let SET_OF_C[T,j,v]:= SET_OF_C[T,j,v] union {n};
								let TREATED := TREATED union {n};
							}
						}	
					}
				}
			}

			#preparing CS for eq25
			for {v in SET_OF_C_FIRST_CLIENTS[T,j] }{
				let SET_OF_C_MIN_DISTANCE_CLIENT[T,j,v] := v;
			}
			#display C_MIN_DISTANCE_CLIENT;
			#choosing closest client to feeder for every connected component in O[j]
			for {v in SET_OF_C_FIRST_CLIENTS[T,j],c in SET_OF_C[T,j,v]}{#,i_cc in C_MIN_DISTANCE_CLIENT[j,v] }{
				if hopcost[j,c] < hopcost[ j , SET_OF_C_MIN_DISTANCE_CLIENT[T,j,v] ] then {
					#let C_MIN_DISTANCE_CLIENT[j,v] := C_MIN_DISTANCE_CLIENT[j,v] diff C_MIN_DISTANCE_CLIENT[j,v];
					let SET_OF_C_MIN_DISTANCE_CLIENT[T,j,v]:=c; #C_MIN_DISTANCE_CLIENT[j,v] union {c};
				}
			}
			for {v in SET_OF_C_FIRST_CLIENTS[T,j], k in SET_OF_CS[T,j]}{#, i_cc in C_MIN_DISTANCE_CLIENT[j,v], k in CS[j]}{
				if (hopcost[j,k]+ hopcost[SET_OF_C_MIN_DISTANCE_CLIENT[T,j,v],k])<= max_distance then
					let SET_OF_CS_RELEVANT_FOR_CC[T,j,v] := SET_OF_CS_RELEVANT_FOR_CC[T,j,v] union {k};
			}
		}
		
		#true if set of customers allocated to feeder j is connected
		if card(SET_OF_O[T,j])=0 then {
			display j;
			#preparing set F
			for {i in CC[j]}{
				if DIST_TO_FEEDER[j,i] = max_distance+1 then {
					let SET_OF_F[T,j] := SET_OF_F[T,j] union {i};
				}
			}
			#display CC[j];
			#display F[j];
			
			if card(SET_OF_F[T,j]) > 0 then {
				#restore eq26;
				let SET_OF_DISTANCE_CUTS_FEEDERS[T] := SET_OF_DISTANCE_CUTS_FEEDERS[T] union {j};
				#display DISTANCE_CUTS_FEEDERS;
				let FEASIBLE := FEASIBLE union {0};
				for {i in SET_OF_F[T,j],k in SET_OF_CS[T,j]}{
					if hopcost[j,k]+hopcost[k,i]<=max_distance then{
						let SET_OF_CS_RELEVANT_FOR_CLIENT_IN_F[T,j,i]:=SET_OF_CS_RELEVANT_FOR_CLIENT_IN_F[T,j,i] union {k};
					}
					#display CS_RELEVANT_FOR_CLIENT_IN_F[j,i];
				}
				
			}
			
		}
	}

	#let SET_OF_O {T,FEEDERS} 
	#let SET_OF_CS {T,j} 
	#let SET_OF_C {T,j,CLIENTS}  
	#let SET_OF_C_FIRST_CLIENTS {T,j} 
	#let SET_OF_C_MIN_DISTANCE_CLIENT {T,j,CLIENTS} 
	#let SET_OF_CS_RELEVANT_FOR_CC{T,j,CLIENTS}
	#let SET_OF_F {T,j} 
	#let SET_OF_CS_RELEVANT_FOR_CLIENT_IN_F{T,j,CLIENTS} 
	#let SET_OF_CONNECTIVITY_CUTS_FEEDERS{T}
	#let SET_OF_DISTANCE_CUTS_FEEDERS{T} 

	
	
}until card(FEASIBLE) =0 ;
#};
