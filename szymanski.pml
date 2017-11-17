/* szymanskis protocol, Taylor Peterson
 */

#define N	4	/* num of processes */
#define L	16	/* size of buffer  (>= 2*N) */


byte flag[N];
int in_critical=0;
byte in_sanctum = 0;
byte line[N];

proctype P (byte i) 
{	
	byte j;

 end:
	do

	////*Noncritical section*//////////
/*line 2: flag[i]:= 1;*/	  
	::printf("Entering NONCritical, %d\n", i);
	flag[i] = 1;
/*line 3: wait until (flag[0] < 3 and flag[1] < 3 and : : : : and flag[N-1] < 3)*/
await1:
	  atomic {
	    for(j:0..(N-1)){
				if
				:: (flag[j] < 3) -> skip;	      
	    	:: else -> goto await1;
	    	fi	      
	  }
	}
	printf("Entering Doorway, %d\n", i);
////*doorway*/
/*line 4: flag[i]:= 3*/
atomic{
		assert(in_sanctum==0);
	  flag[i] = 3;
		line[i] = 1; //waiting room
	}
	printf("Entering Waitng room %d,,,%d\n", i,flag[i]);	
////*waiting room*/
/*line 5: if (flag[0] = 1 or flag[1] = 1 or : : : or flag[N-1] = 1) then */
 	  atomic {
	    for (j:0..(N-1)){
				if  
				::(flag[j] == 1)->
				/*line 6: flag[i] := 2;*/
				flag[i] = 2;
				goto await2;
	      :: else -> skip;
	      fi
	    }
	  }
		goto inner_sanctum;
/*line 7: wait until (flag[0] = 4 or flag[1] = 4 or : : : or flag[N-1] = 4);*/
 await2:
	  printf("Entering await2 %d\n", i);
	  atomic {
	    for (j:0..(N-1)){
				if 
				:: (flag[j] == 4) -> goto inner_sanctum;	      
	      :: else ->  skip;
				fi
			}
	    goto await2
    }

inner_sanctum:
in_sanctum = in_sanctum+1;
printf("Entering Inner Sanctum, %d\n", i);
////*inner sanctum*/
/*line 8: flag[i]:= 4;*/
	  flag[i] = 4;
		printf("Flag[%d]= %d\n", i,flag[i]);
/*line 9: wait until (flag[0] < 2 and flag[1] < 2 and : : : and flag[i-1] < 2)*/
 await3:
	  atomic {
	    for (j:0..(i-1)){
				//assert(flag[j]<4);
				if 
				:: (flag[j] < 2) -> skip;	      
				:: else -> goto await3;
				fi
	    }	      
		}
	
////*Critical Section:*/////////////////// 
/*line 11: wait until (flag[i+1] E 0; 1; 4) and : : : and (flag[N-1] E 0; 1; 4)*/
printf("Entering Critical, %d", i);
/*		for (j:0..(N-1)){
			  if
				:: line[j]==1 ->
				assert(i<j);//assert for part C
				:: else -> skip;
				fi
	    }*/
in_critical = in_critical+1;
assert(in_critical<=1)
 await4:
	  atomic {
	    for (j:(i+1)..(N-1)){
				//assert(flag[j]<4);
				if 
				:: (flag[j] == 0 | flag[j] == 1 | flag[j] == 4) -> skip;  
				:: else -> goto await4;
				fi
	    }	      
		in_critical=in_critical-1;
		in_sanctum = in_sanctum-1; 
/*line 12:flag[i]:= 0;*/
		for (j:0..(N-1)){
			  if
				:: line[j]==1 ->
				assert(flag[j]==4);//assert for part C
				:: else -> skip;
				fi
	    }	
	  flag[i] = 0;
		line[i] = 0; //not critical
		}
	od
}

init {
	byte proc;
	atomic {
		proc = 0;
		do
		:: proc < N ->
			run P (proc);
			line[proc] = 0;
			proc++
		:: proc > N ->
			break
		od
	}
}


