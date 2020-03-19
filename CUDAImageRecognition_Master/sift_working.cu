#include <iostream>
#include <cmath>
#include <vector>
#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc/imgproc.hpp>

using namespace cv;
using namespace std;

const double pi = 3.14159;

double** make_kernel(int kernel_size, double stdev) {
	double exp_arg, sum_y, norm_factor;
	int mean = 0;
	int lower_bound = mean - (kernel_size / 2);
	int* x = new int [kernel_size];
	double* y = new double [kernel_size];
	double** kernel = new double* [kernel_size];
	for (int i = 0; i < kernel_size; i++) {kernel[i] = new double[kernel_size];}
	double k = (1 / (pow(2 * pi, .5) * stdev));

	for (int i = 0; i < (kernel_size); i++) {
		x[i] = lower_bound + i; 
	}

	for (int i = 0; i < kernel_size; i++)
	{
		exp_arg = ( pow(((double)x[i] - mean), 2));
		exp_arg = -(exp_arg / (2 * pow(stdev, 2)));
		y[i] = (k * exp(exp_arg));
		sum_y += y[i];
	}

	norm_factor = 1 / sum_y;

	for (int i = 0; i < kernel_size; i++) {
		y[i] = (y[i] * norm_factor); 
	}

	for (int i = 0; i < kernel_size; i++)
	{

		for (int j = 0; j < kernel_size; j++)
		{
			kernel[i][j] = y[i] * y[j];
		}
	}
	delete x;
	delete y;
	return kernel; 
}

void free_kernel_mem(double** kernel, int kernel_size) {
	for (int i = 0; i < kernel_size; i++) {
		delete kernel[i];
	}
	delete kernel;
}

void showImage(Mat image) {
	namedWindow("Display window", WINDOW_AUTOSIZE);     
    imshow("Display window", image);             
    waitKey(0);                                          
}

int main(int argc, char* argv[])
{
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

    vector<Mat> octaves;
    vector<Mat> LoGs;
	int num_octaves = 5;

	// create octaves with Gaussian Blur 
	for (int octave = 0; octave < num_octaves; octave++) 
	{
		Mat outputImage = image.clone();
		outputImage.setTo(cv::Scalar(0,0,0));
		int kernel_size = 3*pow(sqrt(2),octave);
		int output_height = image.size().height;
		int output_width = image.size().width;
		double** kernel = make_kernel(kernel_size, (double)kernel_size/3.0);
		int x, y;
		for (int i = 0 ; i < output_height; i++)
		{
			for (int j = 0 ; j < output_width; j++)
			{
				for (int k = 0; k < 3; k++)
				{
					for (int h = i - (kernel_size/2); h <= i + (kernel_size/2); h++)
					{
						for (int w = j - (kernel_size/2); w <= j + (kernel_size/2); w++)
						{
							x=h;
							y=w;
							if (h < 0) x=-h;
							else if (h>=output_height) {x=(2*output_height - h -1);}
							if (w < 0) y = -w;
							else if (w>=output_width) {y = (2*output_width - w -1); }
							outputImage.at<Vec3b>(i,j)[k] += 
							kernel[h-i+(kernel_size/2)][w-j+(kernel_size/2)] * image.at<Vec3b>(x,y)[k];
						}
					}
				}	
			}
		}

	for (int i = 0; i < octaves.size(); i++) {
		showImage(octaves[i]);
	}

	for (int curr_octave = 1; curr_octave < num_octaves; curr_octave++) {
		Mat LoG = image.clone();
		for (int i = 0; i < image.size().height; i++) {
			for (int j = 0; j < image.size().width; j++) {
				for (int k = 0; k < 3; k++) {
					LoG.at<Vec3b>(i,j)[k] = abs(
						octaves[curr_octave].at<Vec3b>(i,j)[k] - 
						octaves[curr_octave - 1].at<Vec3b>(i,j)[k]);
				}
			}
		}
		LoGs.push_back(LoG);
	}

	for (int i = 0; i < LoGs.size(); i++) {
		showImage(LoGs[i]);
	}

	for(int curr_octave = 1; curr_octave < 3; curr_octave++) {
		for (int i = 0; i < image.size().height; i++) {
			for (int j = 0; j < image.size().width; j++) {
				bool isGreatest = true;
				bool isLeast = true;
				double d1 = pow(LoGs[curr_octave].at<Vec3b>(i,j)[0],2) + pow(LoGs[curr_octave].at<Vec3b>(i,j)[1],2) + pow(LoGs[curr_octave].at<Vec3b>(i,j)[2],2);
				for (int level = -1; level < 2; level++) {
					if (!isGreatest && !isLeast) {
						break;
					}
					for (int x = -1; x < 2; x++) {
						if (!isGreatest && !isLeast) {
							break;
						}
						for (int y = -1; y < 2; y++) {
							double d2 = pow(LoGs[curr_octave + level].at<Vec3b>(i+x,j+y)[0],2) + 
								 pow(LoGs[curr_octave + level].at<Vec3b>(i+x,j+y)[1],2) + 
								 pow(LoGs[curr_octave + level].at<Vec3b>(i+x,j+y)[2],2);
							if (i+x >= 0 && 
								i+x <  image.size().height &&
								j+y >= 0 &&                 
								j+y <  image.size().width &&
								d1 > d2) 
							{
								isLeast = false;
							}
							if (i+x >= 0 && 
								i+x < image.size().height &&
								j+y >= 0 && 
								j+y < image.size().width &&
								d1 < d2)
							{
								isGreatest = false;
							}
							if (!isGreatest && !isLeast) {
								break;
							} else if (level == 1 && x == 1 && y == 1) {
								image.at<Vec3b>(i,j)[0] = 0;
								image.at<Vec3b>(i,j)[1] = 0;
								image.at<Vec3b>(i,j)[2] = 255;
							}
						}
					}
				}
			}
		}
	}

	showImage(image);

	return 0;
}