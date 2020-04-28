#include <omp.h>
#include <stdio.h>
#include <stdlib.h>


typedef struct _lock_t                                  
{
    int flag;                                           
}struct_m;

int t_and_s (struct_m* oldPtr, int new_p)            
{                                                       
    int old;
    #pragma omp atomic capture
    {
        old = oldPtr->flag;
        oldPtr->flag = new_p;
    }
    return old;
}

void lock_initial(struct_m *lock_m)
{
    lock_m->flag = 0;
}

void m_lock(struct_m *lock_m)
{
    while(t_and_s(lock_m,1) == 1);
}

void m_unlock(struct_m *lock_m)
{
    lock_m->flag = 0;
}

void m_destroy(struct_m *lock_m)
{
    free(lock_m);
}

int main()
{
    int Number;
    int *ptr;
    printf("enter a large value to test on \n");
	scanf("%d", &Number);


	ptr = (int*)malloc(Number * sizeof(int)); 

    int i=0,sum=0;
    for(i=0;i<Number;i++)ptr[i]=1;
    struct_m *lock_m = malloc(sizeof(struct_m));
    lock_initial(lock_m);

    omp_set_num_threads(10); 
    
    printf("printing array values...\n");                       
    for(i=0;i<Number;i++)printf("%d ",ptr[i]);              

    #pragma omp parallel for default (shared) private (i)
    for(i=0;i<Number;i++)
    {
        m_lock(lock_m);                              
        sum+=ptr[i];                                   
        m_unlock(lock_m);
    }

    printf("\n*****************************************\n");
    printf("No of elements to test on: %d\n", Number);
    printf("sum found = %d\n", sum);
    printf("\n*****************************************\n");

    m_destroy(lock_m);

    return 0;
}

