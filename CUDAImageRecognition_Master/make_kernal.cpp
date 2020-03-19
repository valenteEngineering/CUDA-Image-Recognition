#include <iostream>
#include <cmath>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace cv;
using namespace std;


int   kernal_size = 3;
int stdev = kernal_size / 3;
int mean = 0;

const double pi = 3.14159;
double exp_arg, sum_y, norm_factor;





int main()
{
	int lower_bound = mean - (kernal_size / 2);
	int upper_bound = mean - (kernal_size / 2);
	int* x = new int [kernal_size];
	double* y = new double [kernal_size];
	double** kernal = new double* [kernal_size];
	for (int i = 0; i < kernal_size; i++) {kernal[i] = new double[kernal_size];}
	double k = (1 / (pow(2 * pi, .5) * stdev));


	for (int i = 0; i < (kernal_size); i++) {x[i] = lower_bound + i; cout << " " << x[i] << " |";}


	cout << endl;
	for (int i = 0; i < kernal_size; i++)
	{
		exp_arg = ( pow(((double)x[i] - mean), 2));
		exp_arg = -(exp_arg / (2 * pow(stdev, 2)));
		y[i] = (k * exp(exp_arg));
		cout << " " << y[i] << " |";
		sum_y += y[i];
	}

	norm_factor = 1 / sum_y;
	cout << endl;
	for (int i = 0; i < kernal_size; i++) {y[i] = (y[i] * norm_factor); cout << " " << y[i] << " |";}
	for (int i = 0; i < kernal_size; i++)
	{

		cout << endl;
		for (int j = 0; j < kernal_size; j++)
		{
			kernal[i][j] = y[i] * y[j];
			cout << " " << kernal[i][j] << " |";
		}
	}


	//must use periodic or whatever type of edge padding
	// we may split up matrix for convolution but not into
	//blocks which are smaller than the kernal itself


	int output_height = image_height - kernal_size + 1;
	int output_width = image_width - kernal_size + 1;




	for (int d = 0 ; d < 3 ; d++)
	{
		for (int i = 0 ; i < output_height ; i++)
		{
			for (j = 0 ; j < output_width; j++)
			{
				for (h = i ; h < i + kernal_size ; h++)
				{
					for (w = j ; w < j + kernal_size ; w++)
					{
						outputImage[d][i][j] += kernal[h - i][w - j] * image[d][h][w];
					}
				}
			}
		}
	}

	//test












}