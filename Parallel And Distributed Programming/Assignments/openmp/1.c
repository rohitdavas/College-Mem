#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <omp.h>

#define MAX_ELE 50                               
#define MAXSUM 500                         
int table_look_up[MAX_ELE][MAXSUM] = {0};           

int SUM(int ptr[], int n, int sum)
{
    if (sum == 0){return 1;}

    if (n<0 || sum <0){return -1;}

    int inc = 0, exc = 0; 

    if(table_look_up[n][sum] == 0)
    {
        #pragma omp task shared(inc)
		inc = SUM(ptr, n - 1, sum - ptr[n]);

        #pragma omp task shared(exc)    
		exc = SUM(ptr, n - 1, sum);

        #pragma omp taskwait


		if(inc==1 || exc==1)table_look_up[n][sum]=1;
        else table_look_up[n][sum]=-1;
    }

    return table_look_up[n][sum];
}



int main() 
{ 
    //##############################################
	int* ptr; 
	int n, i, sum,answer; 

    printf("Enter the no of elements: ");
	scanf("%d", &n);

	ptr = (int*)malloc(n * sizeof(int)); 

	if (ptr == NULL) 
    { 
     	printf("Memory not allocated.\n"); 
		exit(0); 
	} 

	else 
    { 
		printf("Memory successfully allocated using malloc.\n"); 

		for (i = 0; i < n; ++i) { 
            printf("enter element %d ",i);
			scanf("%d", &ptr[i]); 
		} 
    }

    printf("enter the expected sum value: ");
    scanf("%d", &sum); 


    printf("##########YOU HAVE ENTERED DATA:################\n");
	printf("ARRAY: "); 
	for (i = 0; i < n; ++i) { printf("%d, ", ptr[i]);} 
    printf("\n");
    printf("EXPECTED SUM VALUE: %d\n\n", sum); 

    //#################################################

    int sol;

    #pragma omp parallel
    #pragma omp single
    sol = SUM(ptr, n-1, sum);

    if (sol ==1)
		printf("\n*************\n A subset of that sums to %d is found.\n*************\n ", sum);
	else
		printf("\n***********\nNo subset summing upto %d the given value is found.\n********\n",sum);

	return 0;
    

} 

