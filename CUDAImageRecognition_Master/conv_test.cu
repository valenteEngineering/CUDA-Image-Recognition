#include <iostream> 
#include <cublas.h>
#include <time.h>

#define HEIGHT 1024
#define WIDTH 1024
#define BLOCK_SIZE 32 //this now refers to abstacted block size 
#define kernal_size 3

using namespace std; 


__global__ void matrix_mult(int *a, int *b, int *c){
	int threadRow = threadIdx.y;
	int threadCol = threadIdx.x;


	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;


		__shared__ int a_share[BLOCK_SIZE + kernal_size][BLOCK_SIZE + kernal_size];
		__shared__ int b_share[kernal_size][kernal_size];

		// each thread reads one element from A matrix 
		//think about over indexing a here  
		int get_row = blockDim.y * (HEIGHT/BLOCK_SIZE) + threadIdx.y;
		int get_col = blockDim.x * (WIDTH/BLOCK_SIZE) + threadIdx.x; 
		
		//a_share[threadRow][threadCol] = a[get_row][get_col];
		if (get_row<HEIGHT && get_col<WIDTH ) 
		{
			if (threadRow<(HEIGHT/BLOCK_SIZE) && threadCol<(WIDTH/BLOCK_SIZE))
			{
				a_share[threadRow][threadCol] = a[get_row*WIDTH + get_col];
		    }
		    __syncthreads();
			if (!(threadRow<(HEIGHT/BLOCK_SIZE) && threadCol<(WIDTH/BLOCK_SIZE)))
			{
				a_share[threadRow][threadCol] = a[get_row*WIDTH + get_col];
		    }
			
		}
		//the first kernal_size^2 threads will read in b 
		if (threadRow<kernal_size && threadCol<kernal_size)
		{
			b_share[threadRow][threadCol] = b[threadRow*kernal_size + threadCol];
		}
		// make sure the sub-matrices are loaded before starting the computation
		__syncthreads();

		if (threadRow<BLOCK_SIZE && threadCol<BLOCK_SIZE && get_row< (HEIGHT-kernal_size) 
			&& get_col <(WIDTH-kernal_size))
		{
			for (int i = 0; i<kernal_size; i++)
			{
				
				for (int j = 0; j<kernal_size; j++)
				{
					//c[get_row][get_col]+= b_share[i][j] * a_share[threadRow+i][threadRow+j];
					c[get_row*(WIDTH-kernal_size) + get_col]+= b_share[i][j] * a_share[threadRow+i][threadRow+j];
					
					//c[get_row*(WIDTH-kernal_size) + get_col]+= b_share[i][j];

				}
			}
		}
		// make sure every thread is done computing before loading new sub-matrices
		__syncthreads();

	

	
}

int main(){
	
    int i;
    //int **a = (int**)malloc(sizeof(*int) * HEIGHT);
    //for (int i = 0; i < HEIGHT; i++) a[i] = malloc(sizeof(a[i]) * WIDTH);
    int *a = (int*)malloc(sizeof(int) * HEIGHT * WIDTH);
    //int** a = new *int[HEIGHT];
    //for (int i = 0; i < HEIGHT; i++) a[i] = new int[WIDTH];
	//int** b = new *int[kernal_size];
	//for (int i = 0; i < kernal_size; i++) b[i] = new int[kernal_size];
    //int **b = (int**)malloc(sizeof(*int) * kernal_size);
    //for (int i = 0; i < kernal_size; i++) b[i] = malloc(sizeof(b[i]) * kernal_size);
    int *b = (int*)malloc(sizeof(int) * kernal_size * kernal_size);
	int new_height = HEIGHT - kernal_size +1;
	int new_width = WIDTH - kernal_size +1;
	int *c = (int*)malloc(sizeof(int) * new_height * new_width);
    //int **c = new *int[new_height];
    //for (int i = 0; i < new_height; i++) c[i] = new int[new_width];
    //int **c = (int**)malloc(sizeof(*int) * new_height);
    //for (int i = 0; i < new_height; i++) c[i] = malloc(sizeof(c[i]) * new_width);


	for(int i=0; i<WIDTH; i++)
	{
		for(int j = 0; j<HEIGHT; j++)
		{
			//a[i][j]=1;
			a[i*WIDTH + j] = 1; 
		}
	}
	for (int i = 0; i<kernal_size; i++)
	{
		for(int j =0; j < kernal_size; j++)
		{
			b[i*kernal_size + j] = 1; 
		}
	}

	
  	




	int *gpu_a, *gpu_b, *gpu_c;
	cudaMalloc((void**)&gpu_a, sizeof(int) * HEIGHT * WIDTH);
	cudaMalloc((void**)&gpu_b, sizeof(int) * kernal_size * kernal_size);
	cudaMalloc((void**)&gpu_c, sizeof(int) * new_height * new_width);

	struct timespec start, stop;
	double time;

	cudaMemcpy(gpu_a, a, sizeof(int) * HEIGHT * WIDTH, cudaMemcpyHostToDevice);
	cudaMemcpy(gpu_b, b, sizeof(int) * kernal_size * kernal_size, cudaMemcpyHostToDevice);

	 

	dim3 dimGrid(32, 32);
	dim3 dimBlock(32+kernal_size, 32+kernal_size);

	//if( clock_gettime( CLOCK_REALTIME, &start) == -1 ) { perror( "clock gettime" );}
	cout<<"test"<<endl;
	matrix_mult<<<dimGrid, dimBlock>>>(gpu_a, gpu_b, gpu_c);
	cudaMemcpy(c, gpu_c, sizeof(int) * new_width * new_height, cudaMemcpyDeviceToHost);

	//if( clock_gettime( CLOCK_REALTIME, &stop) == -1 ) { perror( "clock gettime" );}
	//time = (stop.tv_sec - start.tv_sec)+ (double)(stop.tv_nsec - start.tv_nsec)/1e9;
	//printf("time is %f ns\n", time*1e9);

	//printf("c[451][451]=%d\n", c[451*1024+451]);

	
	cout<<"c[451][451]="<<c[451*1024+451];

	free(a);
	free(b);
	free(c);
	cudaFree(gpu_a);
	cudaFree(gpu_b);
	cudaFree(gpu_c);
	return 0;
}
