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
	  atomic {
	    
	  }
	  
////*doorway*/
/*line 4: flag[i]:= 3*/
	  flag[i] = 3;
////*waiting room*/
/*line 5: if (flag[0] = 1 or flag[1] = 1 or : : : or flag[N-1] = 1) then */
	  atomic {


	    /*line 6: flag[i] := 2;*/
	    flag[i] = 2;
	  }
/*line 7: wait until (flag[0] = 4 or flag[1] = 4 or : : : or flag[N-1] = 4);*/
	  atomic {
	    
	  }
////*inner sanctum*/
/*line 8: flag[i]:= 4;*/
	  flag[i] = 4; 
/*line 9: wait until (flag[0] < 2 and flag[1] < 2 and : : : and flag[i-1] < 2)*/
	  atomic {
	    
	  }
        ////*Critical Section:*///////////////////
/*line 11: wait until (flag[i+1] E 0; 1; 4) and : : : and (flag[N-1] E 0; 1; 4)*/
	  atomic {
	    
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


