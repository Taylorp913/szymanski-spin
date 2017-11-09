/* szymanskis protocol
 */

#define N	2	/* num of processes */
#define L	16	/* size of buffer  (>= 2*N) */

byte flag[N];

proctype P ()
{	
	byte k;

 end:
	do
	////*Noncritical section*//////////
/*line 2: flag[i]:= 1;*/	  
	  flag[i] = 1;
/*line 3: wait until (flag[0] < 3 and flag[1] < 3 and : : : : and flag[N-1] < 3)*/
 await1:
	  atomic {
	    for (j:0..N-1){
	      if (flag[j] < 3)
		skip;	      
	    } else {
	      goto await1
	    }	      
	  }
	  
////*doorway*/
/*line 4: flag[i]:= 3*/
	  flag[i] = 3;
////*waiting room*/
/*line 5: if (flag[0] = 1 or flag[1] = 1 or : : : or flag[N-1] = 1) then */
 	  atomic {
	    for (j:0..N-1){
	      if (flag[j] == 1)
		/*line 6: flag[i] := 2;*/
		flag[i] = 2;
	      } else {
	        skip
	      }	      
	    }
	  }
/*line 7: wait until (flag[0] = 4 or flag[1] = 4 or : : : or flag[N-1] = 4);*/
 await2:
	  atomic {
	    for (j:0..N-1){
	      if (flag[j] == 4)
		goto inner_sanctum;	      
	      } else {
	        skip;
	      }
	    goto await2
	    }
          }

inner_sanctum:
////*inner sanctum*/
/*line 8: flag[i]:= 4;*/
	  flag[i] = 4; 
/*line 9: wait until (flag[0] < 2 and flag[1] < 2 and : : : and flag[i-1] < 2)*/
 await3:
	  atomic {
	    for (j:0..N-1){
	      if (flag[j] < 2)
		skip;	      
	    } else {
	      goto await3
	    }	      
	  }
////*Critical Section:*///////////////////
/*line 11: wait until (flag[i+1] E 0; 1; 4) and : : : and (flag[N-1] E 0; 1; 4)*/
 await4:
	  atomic {
	    for (j:i+1..N-1){
	      if (flag[j] == 0 || flag[j] == 1 || flag[j] == 4)
		skip;  
	    } else {
	      goto await4
	    }	      
	  }
/*line 12:flag[i]:= 0;*/
	  flag[i] = 0;
	
	od
}

init {
	byte proc;
	atomic {
		proc = 1;
		do
		:: proc <= N ->
			run node (q[proc-1], q[proc%N], (N+I-proc)%N+1);
			proc++
		:: proc > N ->
			break
		od
	}
}


