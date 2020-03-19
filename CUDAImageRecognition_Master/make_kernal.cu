#include <iostream>
#include <cmath>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace cv;
using namespace std;

int   kernal_size = 3;
int stdev = kernal_size / 3;

const double pi = 3.14159;
double exp_arg, sum_y, norm_factor;

int main(int argc, char* argv[])
{
	int mean = 0;

	// open image 
	if( argc != 2)
    {
     cout <<" Usage: display_image ImageToLoadAndDisplay" << endl;
     return -1;
    }

    Mat image;
    image = imread(argv[1], CV_LOAD_IMAGE_COLOR);   // Read the file

    if(! image.data )                              // Check for invalid input
    {
        cout <<  "Could not open or find the image" << std::endl ;
        return -1;
    }

	int lower_bound = mean - (kernal_size / 2);
	int upper_bound = mean + (kernal_size / 2);
	int* x = new int [kernal_size];
	double* y = new double [kernal_size];
	double** kernal = new double* [kernal_size];
	for (int i = 0; i < kernal_size; i++) {kernal[i] = new double[kernal_size];}
	double k = (1 / (pow(2 * pi, .5) * stdev));

	for (int i = 0; i < (kernal_size); i++) {
		x[i] = lower_bound + i; 
	}

	for (int i = 0; i < kernal_size; i++)
	{
		exp_arg = ( pow(((double)x[i] - mean), 2));
		exp_arg = -(exp_arg / (2 * pow(stdev, 2)));
		y[i] = (k * exp(exp_arg));
		sum_y += y[i];
	}

	norm_factor = 1 / sum_y;

	for (int i = 0; i < kernal_size; i++) {
		y[i] = (y[i] * norm_factor); 
	}

	for (int i = 0; i < kernal_size; i++)
	{

		for (int j = 0; j < kernal_size; j++)
		{
			kernal[i][j] = y[i] * y[j];
		}
	}

	//must use periodic or whatever type of edge padding
	// we may split up matrix for convolution but not into
	//blocks which are smaller than the kernal itself

	Mat outputImage = image.clone();
	outputImage.setTo(cv::Scalar(0,0,0));

	int output_height = image.size().height - kernal_size + 1;
	int output_width = image.size().width - kernal_size + 1;

	for (int i = 0 ; i < output_height ; i++)
	{
		for (int j = 0 ; j < output_width; j++)
		{
			for (int k = 0; k < 3; k++)
			{
				for (int h = i ; h < i + kernal_size ; h++)
				{
					for (int w = j ; w < j + kernal_size ; w++)
					{
						outputImage.at<Vec3b>(i,j)[k] += kernal[h - i][w - j] * image.at<Vec3b>(h,w)[k];
					}
				}
			}	
		}
	}

	namedWindow( "Display window", WINDOW_AUTOSIZE );     // Create a window for display.
    imshow( "Display window", outputImage );             // Show our image inside it.

    waitKey(0);                                          // Wait for a keystroke in the window

	// free memory 
	delete x;
	delete y;
	for (int i = 0; i < kernal_size; i++) {
		delete kernal[i];
	}
	delete kernal;

	return 0;
}